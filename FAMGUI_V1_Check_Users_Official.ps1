Add-Type -AssemblyName PresentationFramework

# Use an ObservableCollection to hold our results
$Results = New-Object System.Collections.ObjectModel.ObservableCollection[Object]

# Function to get permissions for a directory
function Get-PermissionsForDirectory {
    param (
        [string]$DirPath
    )
    
    Write-Host "Processing folder: $DirPath"
    try {
        $ACLs = Get-Acl $DirPath
    }
    catch {
        Write-Warning "Unable to get ACL for $DirPath"
        return
    }
    if ($ACLs.Access.Count -eq 0) {
        Write-Host "No ACLs found for $DirPath"
        return
    }
    $FolderName = [System.IO.Path]::GetFileName($DirPath)
    $Permissions = foreach ($AccessRule in $ACLs.Access) {
        [PSCustomObject]@{
            Name        = $AccessRule.IdentityReference
            Permission  = $AccessRule.FileSystemRights
            AccessType  = $AccessRule.AccessControlType
            IsInherited = $AccessRule.IsInherited
        }
    }
    $Results.Add([PSCustomObject]@{
        Folder      = $FolderName
        Path        = $DirPath
        Permissions = $Permissions
    })
}

# Function to load permissions (for the given path and its immediate subdirectories)
function Load-Permissions {
    $Results.Clear()
    $Path = $TextBox.Text.Trim()
    if (-Not (Test-Path $Path -PathType Container)) {
        [System.Windows.MessageBox]::Show("Invalid directory path!", "Error", "OK", "Error")
        return
    }
    Get-PermissionsForDirectory -DirPath $Path
    $SubDirs = Get-ChildItem $Path -Directory -Force
    foreach ($SubDir in $SubDirs) {
        Get-PermissionsForDirectory -DirPath $SubDir.FullName
    }
    Write-Host "TreeView updated. Total items: $($Results.Count)"
    $TreeView.ItemsSource = $Results
}

# XAML definition: a Grid with three rows:
# Row 0: Controls (TextBox and Load Button)
# Row 1: A header row (labels) that appears only once
# Row 2: A TreeView that displays folder permissions (scrolls if needed)
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Permissions Viewer" Height="600" Width="800" ResizeMode="CanResize">
  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/> <!-- Controls -->
      <RowDefinition Height="Auto"/> <!-- Fixed Header Row -->
      <RowDefinition Height="*"/>    <!-- TreeView Content -->
    </Grid.RowDefinitions>

    <!-- Controls -->
    <StackPanel Orientation="Horizontal" Grid.Row="0" Margin="10">
      <TextBox Name="TextBox" Width="600" Margin="0,0,10,0"/>
      <Button Name="LoadButton" Content="Load" Width="100"/>
    </StackPanel>

    <!-- Fixed Header Row (appears only once) -->
    <StackPanel Orientation="Horizontal" Grid.Row="1" Margin="10,5">
      <TextBlock Text="Name" Width="250" TextAlignment="Center" FontWeight="Bold"/>
      <TextBlock Text="Permission" Width="230" TextAlignment="Center" FontWeight="Bold"/>
      <TextBlock Text="AccessType" Width="150" TextAlignment="Center" FontWeight="Bold"/>
      <TextBlock Text="IsInherited" Width="100" TextAlignment="Center" FontWeight="Bold"/>
    </StackPanel>

    <!-- TreeView Content -->
    <TreeView Name="TreeView" Grid.Row="2" Margin="10">
      <TreeView.ItemTemplate>
        <!-- Each folder is a TreeViewItem whose header shows the folder name -->
        <!-- Its ItemsSource is the collection of permissions for that folder -->
        <HierarchicalDataTemplate ItemsSource="{Binding Permissions}">
          <TextBlock Text="{Binding Folder}" FontWeight="Bold"/>
          <HierarchicalDataTemplate.ItemTemplate>
            <!-- Each permission is shown as a row in a horizontal StackPanel -->
            <DataTemplate>
              <StackPanel Orientation="Horizontal">
                <TextBlock Text="{Binding Name}" Width="260" TextAlignment="Left"/>
                <TextBlock Text="{Binding Permission}" Width="240" TextAlignment="Left"/>
                <TextBlock Text="{Binding AccessType}" Width="130" TextAlignment="Left"/>
                <TextBlock Text="{Binding IsInherited}" Width="100" TextAlignment="Left"/>
              </StackPanel>
            </DataTemplate>
          </HierarchicalDataTemplate.ItemTemplate>
        </HierarchicalDataTemplate>
      </TreeView.ItemTemplate>
    </TreeView>
  </Grid>
</Window>
"@

# Load the XAML
$Reader = (New-Object System.Xml.XmlNodeReader $XAML)
$Window = [Windows.Markup.XamlReader]::Load($Reader)

# Get UI elements by name
$TextBox = $Window.FindName("TextBox")
$LoadButton = $Window.FindName("LoadButton")
$TreeView = $Window.FindName("TreeView")

# (Optional) Set a default path
$TextBox.Text = "Z:\"

# Wire up the Load button's click event
$LoadButton.Add_Click({ Load-Permissions })

# Show the window (discarding the dialog result)
$Window.ShowDialog() | Out-Null
