# --- Configuration ---
# Specify the path to your JSON settings file
$jsonFilePath = $HOME + '\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json' # Assumes the file is in the current directory. Update if needed.

# --- Script Logic ---

# Define the PowerShell Hashtable that represents the desired nested JSON structure for the font setting.
# This Hashtable itself will become the value of the 'font' property.
$fontObjectToAdd = @{
    face = "MesloLGM Nerd Font"
}

# Check if the file exists
if (-not (Test-Path -Path $jsonFilePath -PathType Leaf)) {
    Write-Error "Error: The file '$jsonFilePath' was not found."
    # Exit the script if the file doesn't exist
    exit 1
}

# Read the JSON file content and convert it to a PowerShell object
try {
    Write-Verbose "Reading and parsing JSON file: $jsonFilePath"
    # Get-Content -Raw reads the entire file as a single string, crucial for ConvertFrom-Json
    $jsonObject = Get-Content -Path $jsonFilePath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    Write-Verbose "Successfully parsed JSON file."
}
catch {
    # Output detailed error if reading or parsing fails
    Write-Error "Failed to read or parse the JSON file '$jsonFilePath'. Error: $($_.Exception.Message)"
    # Exit the script on failure
    exit 1
}

# Ensure the path profiles.defaults exists
if ($null -eq $jsonObject.profiles) {
    $jsonObject | Add-Member -MemberType NoteProperty -Name 'profiles' -Value (New-Object -TypeName PSObject)
    Write-Verbose "Created 'profiles' object as it did not exist."
}
if ($null -eq $jsonObject.profiles.defaults) {
    $jsonObject.profiles | Add-Member -MemberType NoteProperty -Name 'defaults' -Value (New-Object -TypeName PSObject)
    Write-Verbose "Created 'profiles.defaults' object as it did not exist."
}

# --- MODIFIED SECTION ---
# Explicitly add or overwrite the 'font' property within profiles.defaults using Add-Member
# This is more robust than direct assignment ($= $) if dynamic property creation fails.
# -MemberType NoteProperty: Specifies we are adding a static property.
# -Name 'font': The name of the property to add/update.
# -Value $fontObjectToAdd: The value to assign (our hashtable representing the font settings).
# -Force: Overwrites the property if it already exists, preventing an error.
try {
    Write-Verbose "Ensuring 'font' property exists under 'profiles.defaults' using Add-Member."
    $jsonObject.profiles.defaults | Add-Member -MemberType NoteProperty -Name 'font' -Value $fontObjectToAdd -Force -ErrorAction Stop
    Write-Verbose "'font' property under 'profiles.defaults' ensured and set."
}
catch {
    Write-Error "Failed to add or update the 'font' property using Add-Member. Error: $($_.Exception.Message)"
    exit 1
}
# --- END OF MODIFIED SECTION ---


# Convert the modified PowerShell object back to a JSON string
# Use -Depth parameter to ensure nested objects (like the new font object) are fully serialized
try {
    Write-Verbose "Converting modified object back to JSON string."
    # Using a high depth value like 10 ensures deep structures are preserved
    $updatedJsonString = $jsonObject | ConvertTo-Json -Depth 10 -ErrorAction Stop
    Write-Verbose "Successfully converted object back to JSON."
}
catch {
    Write-Error "Failed to convert the object back to JSON. Error: $($_.Exception.Message)"
    exit 1
}


# Write the updated JSON string back to the file, using UTF8 encoding
try {
    Write-Verbose "Writing updated JSON back to file: $jsonFilePath"
    # Use Set-Content with UTF8 encoding for compatibility
    $updatedJsonString | Set-Content -Path $jsonFilePath -Encoding UTF8 -ErrorAction Stop
    Write-Host "Successfully updated '$jsonFilePath' with the font setting under profiles.defaults."
}
catch {
    # Output detailed error if writing fails
    Write-Error "Failed to write the updated JSON back to '$jsonFilePath'. Error: $($_.Exception.Message)"
    exit 1
}

# --- End of Script ---