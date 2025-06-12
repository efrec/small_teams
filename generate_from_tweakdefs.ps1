# Convert our bespoke tweakdef to a player-friendly version
# and then minify it and get its URL-safe base64 encoding

#-- Config ---------------------------------------------------------------------

$base_dir = 'D:\vscode\proj\beyond-all-reason\small_teams'

$tweakdef = '.\tweakdefs.lua'
$encoding = '.\tweakdefs_encoding.lua'
$minified = '.\tweakdefs_minified.lua'
$min_code = '.\tweakdefs_minified_encoding.txt'
$git_gist = '.\gist.md'

# frankly inadviseable regexery:
$substitutions = @{
    '(?sm)\A--[\s\S]+?(?=^local)'                                          = "---small_teams_tweak`n"
    'local units = \{\}\r?\n'                                              = ''
    '(?sm)\r?\nlocal function (deep|diff|dumb_equal)[\s\S\r\n]+?^end\r?\n' = ''
    '(?sm)^\tif unitDef and not units[\s\S\r\n]+?\tend\r?\n'               = ''
    '(?sm)[- \r\n]+Convert to tweakunits.+\r?\n\z'                         = ''
}

$headings = @{
    minified = 'Tweakdefs'
    encoding = 'Tweakdefs base64'
}

#-- Code -----------------------------------------------------------------------

$content = Get-Content -Path $base_dir\$tweakdef -Raw | Out-String

# Run in BAR to get tweakunits from infolog (todo: write it to file directly).
$encoding_content = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([string] $content))
$encoding_content = $encoding_content.TrimEnd('=') -replace '\+', '-' -replace '/', '_'
Set-Content -Path $base_dir\$encoding -Value $encoding_content -Force -EA 0

$substitutions.GetEnumerator() | ForEach-Object {
    $content = $content -replace $_.Key, $_.Value
}

# User-facing tweakdefs have some utils removed first.
$minified_readable = $content

if (-not (Get-Command luamin -EA 0)) {
    npm install -g luamin
}
$content = luamin -c $content

$minified_content = $content
Set-Content -Path $base_dir\$minified -Value $minified_content -Force -EA 0

# The final encoding is further reduced and minified to be as small as possible.
$content = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([string] $content))
$content = $content.TrimEnd('=') -replace '\+', '-' -replace '/', '_'

$min_code_content = $content
if ($null -eq $min_code_content -or $min_code_content.Length -eq 0) {
    echo 'encoding failure'
}
else {
    Set-Content -Path $base_dir\$min_code -Value $min_code_content -Force -EA 0
}

# The gist contains portions of all the previous in a markdown document.
$markdown = Get-Content -Path $base_dir\$git_gist -Raw | Out-String

$heading = $headings.minified
$code = $minified_readable

$markdown = [regex]::Replace(
    $markdown,
    ('(?sm)(#### $heading(?:\r?\n)+```lua).*?(```)' -replace '\$heading', $heading),
    {
        param($m)
        "$($m.Groups[1].Value)`n$code`n$($m.Groups[2].Value)" 
    }
)

$heading = $headings.encoding
$code = $min_code_content

$markdown = [regex]::Replace(
    $markdown,
    ('(?sm)(#### $heading(?:\r?\n)+>).*?(\z)' -replace '\$heading', $heading),
    {
        param($m)
        "$($m.Groups[1].Value)`n$code`n$($m.Groups[2].Value)" 
    }
)

Set-Content -Path $base_dir\$git_gist -Value $markdown -Force -EA 0