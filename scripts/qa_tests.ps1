$ErrorActionPreference = 'Continue'
$base = "http://localhost:5000/api/v1"

# ── Login ──────────────────────────────────────────────────────
function Login($user, $pass) {
    $body = @{ Usuario = $user; "Contraseña" = $pass } | ConvertTo-Json
    $r = Invoke-RestMethod -Uri "$base/Auth/login" -Method POST -ContentType "application/json" -Body $body
    return $r.datos
}

function Api($method, $path, $token, $body = $null) {
    $headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
    try {
        if ($body) {
            $r = Invoke-WebRequest -Uri "$base$path" -Method $method -Headers $headers -Body $body -ErrorAction Stop
        } else {
            $r = Invoke-WebRequest -Uri "$base$path" -Method $method -Headers $headers -ErrorAction Stop
        }
        return @{ Status = [int]$r.StatusCode; Body = ($r.Content | ConvertFrom-Json) }
    } catch {
        $status = 0
        $respBody = $null
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $reader = [System.IO.StreamReader]::new($stream)
                $respBody = $reader.ReadToEnd() | ConvertFrom-Json
            } catch {}
        }
        return @{ Status = $status; Body = $respBody; Error = $_.Exception.Message }
    }
}

Write-Host "===== LOGIN =====" -ForegroundColor Cyan
$admin = Login "Admin" "changeme"
$sup   = Login "Supervisor" "changeme"
$op    = Login "Operador Uno" "changeme"
Write-Host "Admin(id=$($admin.id_Usuario)) Sup(id=$($sup.id_Usuario)) Op(id=$($op.id_Usuario))"

Write-Host ""
Write-Host "===== T2: BLOQUEO DE REASIGNACION =====" -ForegroundColor Cyan
# Supervisor (rol=1) intenta reasignar ticket 3 (asignado a Operador user 3) a si mismo
$r = Api "PATCH" "/Tickets/3/asignar" $sup.token '{"Id_Usuario_Asignado":2}'
if ($r.Status -ge 400) {
    Write-Host "T2 PASS: Supervisor bloqueado. Status=$($r.Status) Msg=$($r.Body.mensaje)" -ForegroundColor Green
} else {
    Write-Host "T2 FAIL: Supervisor pudo reasignar. Status=$($r.Status)" -ForegroundColor Red
}

Write-Host ""
Write-Host "===== T3: COMENTARIO OBLIGATORIO EN REASIGNACION =====" -ForegroundColor Cyan
# Admin intenta reasignar ticket 3 (asignado a user 3) a user 2, SIN comentario
$r = Api "PATCH" "/Tickets/3/asignar" $admin.token '{"Id_Usuario_Asignado":2}'
if ($r.Status -ge 400) {
    Write-Host "T3a PASS: Admin bloqueado sin comentario. Status=$($r.Status) Msg=$($r.Body.mensaje)" -ForegroundColor Green
} else {
    Write-Host "T3a FAIL: Admin pudo reasignar sin comentario. Status=$($r.Status)" -ForegroundColor Red
}

# Admin intenta reasignar con comentario vacio
$r = Api "PATCH" "/Tickets/3/asignar" $admin.token '{"Id_Usuario_Asignado":2,"Comentario":""}'
if ($r.Status -ge 400) {
    Write-Host "T3b PASS: Admin bloqueado con comentario vacio. Status=$($r.Status) Msg=$($r.Body.mensaje)" -ForegroundColor Green
} else {
    Write-Host "T3b FAIL: Admin pudo reasignar con comentario vacio. Status=$($r.Status)" -ForegroundColor Red
}

# Admin reasigna CON comentario (debe funcionar)
$r = Api "PATCH" "/Tickets/3/asignar" $admin.token '{"Id_Usuario_Asignado":2,"Comentario":"Reasignando por QA test - urgente"}'
if ($r.Status -eq 200) {
    Write-Host "T3c PASS: Admin reasigno con comentario. Status=$($r.Status)" -ForegroundColor Green
} else {
    Write-Host "T3c FAIL: Admin no pudo reasignar con comentario. Status=$($r.Status) Msg=$($r.Body.mensaje)" -ForegroundColor Red
}

Write-Host ""
Write-Host "===== T4: TRANSICION PROHIBIDA (Cerrado -> En Espera por Operador) =====" -ForegroundColor Cyan
# Crear un ticket, asignar al admin, cerrar, luego Operador intenta transicionar
$r = Api "POST" "/Tickets" $admin.token '{"Contenido":"Test Transicion Prohibida","Id_Prioridad":1,"Id_Departamento":1}'
$tkt4Id = $r.Body.datos.id
Write-Host "Ticket #$tkt4Id creado"

# Admin se auto-asigna
$r = Api "PATCH" "/Tickets/$tkt4Id/asignar" $admin.token '{"Id_Usuario_Asignado":1}'
Write-Host "Asignado a Admin: Status=$($r.Status)"

# Admin: Abierto(1) -> En Proceso(2)
$r = Api "PATCH" "/Tickets/$tkt4Id/cambiar-estado" $admin.token '{"Id_Estado_Nuevo":2,"Comentario":"Iniciando trabajo"}'
Write-Host "Abierto->EnProceso: Status=$($r.Status)"

# Admin: En Proceso(2) -> Resuelto(6)
$r = Api "PATCH" "/Tickets/$tkt4Id/cambiar-estado" $admin.token '{"Id_Estado_Nuevo":6,"Comentario":"Resolviendo"}'
Write-Host "EnProceso->Resuelto: Status=$($r.Status)"

# Admin: Resuelto(6) -> Cerrado(3)
$r = Api "PATCH" "/Tickets/$tkt4Id/cambiar-estado" $admin.token '{"Id_Estado_Nuevo":3,"Comentario":"Cerrando"}'
Write-Host "Resuelto->Cerrado: Status=$($r.Status)"

# Operador intenta: Cerrado(3) -> En Espera(4)
$r = Api "PATCH" "/Tickets/$tkt4Id/cambiar-estado" $op.token '{"Id_Estado_Nuevo":4,"Comentario":"Intento prohibido"}'
if ($r.Status -ge 400) {
    Write-Host "T4 PASS: Transicion Cerrado->EnEspera bloqueada. Status=$($r.Status) Msg=$($r.Body.mensaje)" -ForegroundColor Green
} else {
    Write-Host "T4 FAIL: Operador pudo transicionar Cerrado->EnEspera. Status=$($r.Status)" -ForegroundColor Red
}

Write-Host ""
Write-Host "===== T5: COLA POST-ASIGNACION =====" -ForegroundColor Cyan
$r = Api "GET" "/Tickets?Vista=cola" $sup.token
$colaCount = $r.Body.datos.totalRegistros
Write-Host "Cola actual: $colaCount tickets sin asignar"

$r = Api "POST" "/Tickets" $op.token '{"Contenido":"Ticket sin asignar para cola","Id_Prioridad":2,"Id_Departamento":1}'
$tkt5Id = $r.Body.datos.id
Write-Host "Ticket #$tkt5Id creado (sin asignar)"

$r = Api "GET" "/Tickets?Vista=cola" $sup.token
$colaCount2 = $r.Body.datos.totalRegistros
if ($colaCount2 -gt $colaCount) {
    Write-Host "T5 PASS: Ticket sin asignar aparece en Cola ($colaCount -> $colaCount2)" -ForegroundColor Green
} else {
    Write-Host "T5 FAIL: Ticket sin asignar NO aparece en Cola ($colaCount -> $colaCount2)" -ForegroundColor Red
}

Write-Host ""
Write-Host "===== FIN =====" -ForegroundColor Yellow
