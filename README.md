# Idea Bulut's Toolbelt for Copado

Welcome to Idea Bulut's Toolbelt for Copado. This repository contains a collection of tools and utilities that I use to make  life easier for Copado Release Managers and Developers.

Latest version link: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t8d000000EfmfAAC

0.1.0: https://login.salesforce.com/packaging/installPackage.apexp?p0=04t8d000000EfhZAAS

## Features
 
### Scheduled Deployment File Remover
 - Featured inspired by below idea, to automatically free up storage space on the Copado org
 - Activate Scheduled Deployment File Remover flow

### Auto select Attach file to deployment
 - Feature inspired by the idea posted on the Copado community: [Allow a way to attach deployment files by default when a User Story is promoted through 'Promote and Deploy'](https://success.copado.com/s/idea-list#0875p000000D7tSAAS)
 - Activate Auto select Attach file to deployment flow

### Prevention of deployment of a user story past its base branch
 - Feature inspired by the idea posted on the Copado community: [Improved Base Branch Enforcement for User Story Deployments](https://success.copado.com/s/idea-list#0875p000000D7tNAAS)
 - Activate User Story Current Branch Calculation flow
 - Assign Toolbelt for Copado - User Story Base Branch Control permission set to your users

### User story title addition
 - Adds the value of a user story field, by default the Jira key, to the start or the end of the user story title, for example `[PROJ-1234] Add new object` or `Add new object [PROJ-1234]`
 - When the key changes the tag is replaced, and when the key is cleared the tag is removed
 - Configure it in Setup > Custom Metadata Types > Toolbelt Setting > Default:
   - User Story Title Addition Enabled: turns the feature on (off by default)
   - User Story Title Addition Field: API name of the user story field to add, `copadoccmint__JIRA_key__c` by default
   - User Story Title Addition Mode: `Prefix` or `Suffix`
   - User Story Title Allow Truncation: when the title would exceed 255 characters, cut the end of the original title. When unchecked, the text is not cut and the addition is left out (a tag for an old key is removed so the title never shows the wrong key)

## Change log
- Unreleased
  - User story title addition
- 1.0.0
  - Fixed empty user story base branch causing flow to fail problem
- 0.2.0
  - Prevention of deployment of a user story past its base branch
- 0.1.0
  - Initial release
