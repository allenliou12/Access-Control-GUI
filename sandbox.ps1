$path = "C:\Users\junyi.l\Desktop\Test folder"
$acl = Get-Acl -Path $path
$acl.Access | Format-List
