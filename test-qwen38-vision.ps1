$ErrorActionPreference = "Stop"

$imagePath = "C:\tmp\qwen38test.png"
$endpoint = "http://gravitydrive.local:8080/v1/chat/completions"

if (-not (Test-Path -LiteralPath $imagePath -PathType Leaf)) {
    throw "Image not found: $imagePath"
}

$imageBase64 = [Convert]::ToBase64String(
    [System.IO.File]::ReadAllBytes($imagePath)
)

$request = @{
    model = "Qwen3.8-27B"
    messages = @(
        @{
            role = "user"
            content = @(
                @{
                    type = "text"
                    text = "Describe this screenshot and identify the visible application."
                }
                @{
                    type = "image_url"
                    image_url = @{
                        url = "data:image/png;base64,$imageBase64"
                    }
                }
            )
        }
    )
    max_tokens = 256
    stream = $false
    chat_template_kwargs = @{
        enable_thinking = $false
    }
}

$body = $request | ConvertTo-Json -Depth 10 -Compress

$response = Invoke-RestMethod `
    -Uri $endpoint `
    -Method Post `
    -ContentType "application/json" `
    -TimeoutSec 120 `
    -Body $body

$response.choices[0].message.content
