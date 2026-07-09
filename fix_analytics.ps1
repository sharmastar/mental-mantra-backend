$file = "c:\Users\kuldeep\OneDrive\Desktop\mental mantra\lib\services\analytics_service.dart"
$lines = Get-Content $file
# Find the line with the class closing brace followed by duplicate code
# The new code ends at line that has just "}" before the duplicate starts
$cutAt = 0
for ($i = $lines.Count - 1; $i -ge 0; $i--) {
    if ($lines[$i].Trim() -eq '}' -and $i -gt 100) {
        # Check if this is the FIRST closing brace of the class (not duplicated)
        # The duplicate starts after the class ends
        $cutAt = $i
        break
    }
}
Write-Host "Cutting at line $($cutAt + 1) of $($lines.Count)"
$lines[0..$cutAt] | Set-Content $file
Write-Host "Done"
