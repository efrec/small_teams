# Convert our bespoke tweakdef to a player-friendly version
# and then minify it and get its URL-safe base64 encoding

#-- Config ---------------------------------------------------------------------

$base_dir = 'D:\vscode\proj\beyond-all-reason\small_teams'

$tweakdef = '.\tweakdefs.lua'
$minified = '.\tweakdefs_minified.lua'
$encoding = '.\tweakdefs_minified_encoding.txt'
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

$substitutions.GetEnumerator() | ForEach-Object {
    $content = $content -replace $_.Key, $_.Value
}

$minified_readable = $content

if (-not (Get-Command luamin -EA 0)) {
    npm install -g luamin
}
$content = luamin -c $content

$minified_content = $content
Set-Content -Path $base_dir\$minified -Value $minified_content -Force -EA 0

$content = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([string] $content))
$content = $content.TrimEnd('=') -replace '\+', '-' -replace '/', '_'

$encoding_content = $content
if ($null -eq $encoding_content -or $encoding_content.Length -eq 0) {
    echo 'encoding failure'
}
else {
    Set-Content -Path $base_dir\$encoding -Value $encoding_content -Force -EA 0
}

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
$code = $encoding_content

$markdown = [regex]::Replace(
    $markdown,
    ('(?sm)(#### $heading(?:\r?\n)+>).*?(\z)' -replace '\$heading', $heading),
    {
        param($m)
        "$($m.Groups[1].Value)`n$code`n$($m.Groups[2].Value)" 
    }
)

Set-Content -Path $base_dir\$git_gist -Value $markdown -Force -EA 0