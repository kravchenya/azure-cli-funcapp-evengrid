# azure-cli-funcapp-evengrid

# Azure CLI sample with Blob Storage, Azure Function and Event Grid

This repository contains a sample azure cli bash script and .NET Core Azure Function. The script creates a Blob Storage with a Container, a Storage Account for Azure Function,  Azure Function itself, deploys code from local Git repository to it, and finally registers event grid action (whenever there any changes to blob storage's container done, an Azure Function is invoked).

## Prerequisites

In order to get everything running, you would need to install at least
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?view=azure-cli-latest&tabs=azure-cli) to you local machine
- [Git](https://git-scm.com/downloads)
- (optionally only for Windows OS) You need to use POSIX-compatible runtime environment (more details are provided below)

### Notes

While working on this script I experienced several issues. I mention all of them with possible solutions below

- You may need to enable Microsoft.EventGrid in your Azure subscription. More details how to do it you can find via [link](https://docs.microsoft.com/en-us/azure/event-grid/custom-event-quickstart-portal)

- While using Windows as my main OS in a bundle with Git Bash, I saw stange behaviou, which I believe roots to Git Bash. The problem was that the path with installed Git was concatenated with az components specific path. Everything together looked like "C:/Program Files/Git/subscriptions/XXXX-XXXX-XXXX-XXXX/resourceGroups/YYYY/providers/Microsoft.Storage/storageAccounts/ZZZZ/providers/Microsoft.EventGrid/eventSubscriptions/WWWW?api-version=2020-04-01-preview" and led to errors from az. This behaviour was described alredy in this [issue report](https://github.com/MicrosoftDocs/azure-docs/issues/24857). A possible solution could be a switch to PowerShell script. In my case I gave a try to another runtime environment capable to execute bash script on Windows machines - [Cygwin](https://www.cygwin.com/). The solution let me proceed, however brought other glitches later

  - First I had to replace EOL in a script file. F.e. you can read how to do it in [Notepad++](https://stackoverflow.com/questions/16239551/eol-conversion-in-notepad)

  - The next issue was that Cygwin added carriage return symbol (%0D) to variables, which again led to errors from az. How resolve this pitfall you can read [here](https://stackoverflow.com/questions/20185095/remove-0d-from-variable-in-bash)

- While tring it out many time the same script in a sequence, I had to delete a remote link from my repository. How to do, one can read in this [document](https://docs.github.com/en/github/using-git/removing-a-remote)

- When I started to write this script, I had to decide, whether to use a local Git repository or a remote one. I chose the first one. However if you tend to the second one, you may need to do some extra configuration in Azure and in GitHub. More details about it you can find [here](https://docs.microsoft.com/en-us/azure/devops/boards/github/connect-to-github?view=azure-devops#register-azure-devops-in-github-as-an-oauth-app)

- And at the end. Very useful link. While working on my script I used these [azure cli samples](https://github.com/Azure-Samples/azure-cli-samples) a lot and believe they are very handy for further scripting.
