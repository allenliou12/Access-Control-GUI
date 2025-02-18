Add-Type -AssemblyName PresentationFramework

# Use ObservableCollection for better binding
$Results = New-Object System.Collections.ObjectModel.ObservableCollection[Object]

# Define available permissions for dropdown
$AvailablePermissions = @("Full Access", "Modify", "Read & Execute", "Read", "Write", "None")

function Get-PermissionsForDirectory {
    param (
        [string]$DirPath
    )
    
    Write-Host "Processing folder: $DirPath"  # Log the directory being processed

    try {
        $ACLs = Get-Acl $DirPath
    }
    catch {
        Write-Warning "Unable to get ACL for $DirPath"
        return
    }

    # If no ACLs are returned, skip this folder
    if ($ACLs.Access.Count -eq 0) {
        Write-Host "No ACLs found for $DirPath"
        return
    }

    $FolderName = [System.IO.Path]::GetFileName($DirPath)

    # Gather permissions
    $Permissions = foreach ($AccessRule in $ACLs.Access) {
        [PSCustomObject]@{
            Name       = $AccessRule.IdentityReference
            Permission = $AccessRule.FileSystemRights
            NewPermission = $AccessRule.FileSystemRights # Bind NewPermission to the current permission by default
        }
    }

    # Add the folder and its permissions to Results
    $Results.Add([PSCustomObject]@{
        Folder   = $FolderName
        Path     = $DirPath
        Permissions  = $Permissions
    })

}

function Load-Permissions {
    $Results.Clear()
    $Path = $TextBox.Text.Trim()

    if (-Not (Test-Path $Path -PathType Container)) {
        [System.Windows.MessageBox]::Show("Invalid directory path!", "Error", "OK", "Error")
        return
    }

    Write-Host "Loading permissions for: $Path"

    # Call Get-PermissionsForDirectory for the root directory
    Get-PermissionsForDirectory -DirPath $Path

    # Get immediate subdirectories (no recursion for now)
    $SubDirs = Get-ChildItem $Path -Directory -Force
    foreach ($SubDir in $SubDirs) {
        Get-PermissionsForDirectory -DirPath $SubDir.FullName
    }

    Write-Host "TreeView updated. Total items: $($Results.Count)"

    # Ensure that the TreeView gets the correct DataContext
    $TreeView.ItemsSource = $Results
}

# XAML UI for WPF
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Permissions Viewer" Height="500" Width="800" ResizeMode="CanResize">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <!-- Controls: TextBox and Load Button -->
        <StackPanel Orientation="Horizontal" Grid.Row="0" Margin="10">
            <TextBox Name="TextBox" Width="600" Margin="0,0,10,0"/>
            <Button Name="LoadButton" Content="Load" Width="100"/>
        </StackPanel>

        <!-- Header Row (labels) -->
        <StackPanel Orientation="Horizontal" Grid.Row="1" Margin="10,5">
            <TextBlock Text="Name" Width="260" TextAlignment="Center" FontWeight="Bold"/>
            <TextBlock Text="Permission" Width="280" TextAlignment="Center" FontWeight="Bold"/>
            <TextBlock Text="New Permission" Width="200" TextAlignment="Center" FontWeight="Bold"/>
        </StackPanel>

        <!-- TreeView Content -->
        <TreeView Name="TreeView" Grid.Row="2" Margin="10">
            <TreeView.ItemTemplate>
                <!-- Item Template for Folders -->
                <HierarchicalDataTemplate ItemsSource="{Binding Permissions}">
                    <TextBlock Text="{Binding Folder}" 
                               TextWrapping="Wrap" 
                               FontWeight="Bold"
                               HorizontalAlignment="Stretch"/>
                    
                    <!-- Item Template for Permissions -->
                    <HierarchicalDataTemplate.ItemTemplate>
                        <DataTemplate>
                            <UniformGrid Columns="3" HorizontalAlignment="Stretch">
                                <!-- Name Column -->
                                <TextBlock Text="{Binding Name}" 
                                           Width="260"
                                           TextAlignment="Left"
                                           Padding="5"
                                           HorizontalAlignment="Left"/>

                                <!-- Current Permission Column (Text Display) -->
                                <TextBlock Text="{Binding Permission}" 
                                           Width="240"
                                           TextAlignment="Left"
                                           Padding="5"
                                           HorizontalAlignment="Left"/>

                                <!-- New Permission Column (Dropdown) -->
                                <ComboBox Width="150" 
                                          ItemsSource="{Binding RelativeSource={RelativeSource AncestorType=Window}, Path=DataContext.AvailablePermissions}" 
                                          SelectedItem="{Binding NewPermission, Mode=TwoWay}" 
                                          HorizontalAlignment="Left"/>
                            </UniformGrid>
                        </DataTemplate>
                    </HierarchicalDataTemplate.ItemTemplate>
                </HierarchicalDataTemplate>
            </TreeView.ItemTemplate>
        </TreeView>
    </Grid>
</Window>
"@

# Load XAML
$Reader = (New-Object System.Xml.XmlNodeReader $XAML)
$Window = [Windows.Markup.XamlReader]::Load($Reader)

# Get UI Elements
$TextBox = $Window.FindName("TextBox")
$LoadButton = $Window.FindName("LoadButton")
$TreeView = $Window.FindName("TreeView")

# Set default path (optional)
$TextBox.Text = "Z:\"

# Bind the AvailablePermissions to the window's DataContext
$Window.DataContext = New-Object PSObject -Property @{ AvailablePermissions = $AvailablePermissions }

# Add event handler for button click
$LoadButton.Add_Click({ Load-Permissions })

# Show GUI
$Window.ShowDialog() | Out-Null
