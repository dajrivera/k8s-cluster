 [CmdletBinding()]
 param (
     [Parameter()]
     [string]
     $EnvioronmentPath
 )
 
$ProjectRoot = git rev-parse --show-toplevel

 kubectl kustomize .\kustomize\overlays\dev\infra\cilium\ --load-restrictor LoadRestrictionsNone --enable-helm -o .\manifests\dev\infra\cilium\