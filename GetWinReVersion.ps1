################################################################################################

#

# Copyright (c) Microsoft Corporation.

# Licensed under the MIT License.

#

# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

# SOFTWARE.

#

################################################################################################
# Function to get WinRE path

function GetWinREPath {

    $WinRELocation = (reagentc /info | Select-String "Windows RE location")

    if ($WinRELocation) {

        return $WinRELocation.ToString().Split(':')[-1].Trim()

    } else {

        Write-Host "Failed to find WinRE path" -ForegroundColor Red

        exit 1

    }

}

 
# Creates and needs to be return the mount directory
function GetMountDir {
    # systemdirve\mnt
    $MountDir = "$env:SystemDrive\mnt"
    if (-not (Test-Path $MountDir)) {
        New-Item -ItemType Directory -Path $MountDir -Force | Out-Null
    }
    return $MountDir
}  

# Function to get WinRE version
function GetWinREVersion {

    $mountedPath = GetMountDir
    $filePath = "$mountedPath\Windows\System32\winpeshl.exe"

    $WinREVersion = (Get-Item $filePath).VersionInfo.FileVersionRaw.Revision

    return [int]$WinREVersion

}


# Main Execution

$WinREPath = GetWinREPath


# Make dir C:\mnt if not exists

$TempDir = GetMountDir


# Get the read write permission for this directory

if (-not (Test-Path $TempDir)) {

    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

}


# Mount WinRE image

dism /Mount-Image /ImageFile:"$WinREPath\winre.wim" /Index:1 /MountDir:"$TempDir"


$WinREVersion = GetWinREVersion

Write-Host "WinRE Version: $WinREVersion" -ForegroundColor Cyan

dism /Unmount-Image /MountDir:"$TempDir" /Discard

Remove-Item -Path $TempDir -Force -Recurse