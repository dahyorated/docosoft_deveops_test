az login --scope https://dev.azure.com//.default

# Make sure you're logged in interactively
$subscriptionId = "d0afe958-a32a-4df1-86d2-672fa1a7f707"

# Login and suppress output
az login --only-show-errors | Out-Null

# Set default subscription silently
az account set --subscription $subscriptionId

# Set these before running
$organization = "zikkyway"
$project = "docosofttest"
$sourceBranch = "feature"
$targetBranch = "main"

$optionalReviewers = @(
    "ceo@hibizatogs.org"
)

# Load PR description
$descriptionPath = "pr_description.md"
$prDescription = Get-Content $descriptionPath -Raw

# Get Azure DevOps access token using az cli
$tokenResult = az account get-access-token  --query accessToken --output tsv #--resource https://dev.azure.com/ --query accessToken --output tsv
$headers = @{ Authorization = "Bearer $tokenResult" }

# Get all repos in project
$reposUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=7.0"
$reposResponse = Invoke-RestMethod -Uri $reposUrl -Headers $headers -Method Get
$repos = $reposResponse.value

# Prompt repo selection
Write-Host "Select repos to create Pull Requests in:"
$selectedRepos = $repos | Out-GridView -Title "Select Repositories" -PassThru

foreach ($repo in $selectedRepos) {
    $repoId = $repo.id
    $repoName = $repo.name

    Write-Host "`nCreating PR for repo: $repoName..."

    # Find reviewers
    $reviewers = @()

    # Get all users in org (Graph API)
    $userListUrl = "https://vssps.dev.azure.com/$organization/_apis/graph/users?api-version=7.0-preview.1"
    $userList = Invoke-RestMethod -Uri $userListUrl -Headers $headers -Method Get

    foreach ($reviewer in $optionalReviewers) {
        $matchedUser = $userList.value | Where-Object {
            $_.mailAddress -eq $reviewer -or $_.principalName -eq $reviewer
        }

        if ($matchedUser) {
            $descriptor = $matchedUser.originId
            $reviewers += @{ id = $descriptor }  # 👈 use descriptor directly here
            Write-Host "✅ Reviewer added: $($matchedUser.displayName)"
        } else {
            Write-Warning "❌ Reviewer $reviewer not found in DevOps org."
        }
    }

    # Construct PR body
    $prBody = @{
        sourceRefName = "refs/heads/$sourceBranch"
        targetRefName = "refs/heads/$targetBranch"
        title         = "Automated PR for $repoName"
        description   = $prDescription
        reviewers     = $reviewers
    }

    $createPrUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repoId/pullrequests?api-version=7.0"
    $bodyJson = $prBody | ConvertTo-Json -Depth 5

    try {
        $prResponse = Invoke-RestMethod -Uri $createPrUrl -Headers $headers -Method Post -Body $bodyJson -ContentType "application/json"
        Write-Host "✅ PR created: $($prResponse.pullRequestId) - $($prResponse.title)"
    } catch {
        Write-Host "❌ Failed to create PR for $repoName. Error: $_"
    }
}
