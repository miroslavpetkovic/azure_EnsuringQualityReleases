# azure_EnsuringQualityReleases

Udacity project to ensure the quality releases 

## Introduction
In this project, you will create an environment, delivery of a software, the automated testing of the software and the performance monitoring of the environment under different conditions.

## Getting Started
Befor you even get ready to build the code:
1. Be familiar with these tools:
   * Azure DevOps
   * Selenium
   * Terraform
   * JMeter
   * Postman
2. Create a GitHub repository
3. Create a disposable Outlook account
4. Create a free Azure Account
5. Install Azure CLI or use cloud shell
6. Use your favorite IDE or a text editor
7. Make a plan
8. Read the project several times

## Dependencies
To do before you run the code:

1. Install Terraform
2. Install JMeter
3. Install Postman
4. Install Python
5. Install Selenium

## Instructions
After you have collected your dependencies, the first thing you will do is to start with Terraform.

  **1. Terraform**
 - Create a Service Principal for Terraform named `TerraformSP` by: `az ad sp create-for-rbac --role="Contributor" --name="TerraformSP"`, and such command outputs 5  values: `appId`, `displayName`, `name`, `password`, and `tenant`.

  -  Insert these information to [terraform/environments/test/main.tf](terraform/environments/test/main.tf), where `client_id` and `client_secret` are `appId` and `password`, respectively, as well as `tenant_id` is Azure Tenant ID and `subscription_id` is the Azure Subscription ID and both can be retrieved from the command `az account show` (`subscription_id` is the `id` key of `az account show`).

    ```
    provider "azurerm" {
        tenant_id       = "${var.tenant_id}"
        subscription_id = "${var.subscription_id}"
        client_id       = "${var.client_id}"
        client_secret   = "${var.client_secret}"
        features {}
    }
    ```

 - Since it is not a good practice to expose these sensitive Azure account information to the public github repo,  terraform/environments/test/terraform.tfvars was imported on DevOps portal

 - [Configure the storage account and state backend.](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)

    For the sake of simplicity, run the bash script [config_storage_account.sh](config_storage_account.sh) in the local computer. Then replace the values below in [terraform/environments/test/main.tf](terraform/environments/test/main.tf) with the output from the Azure CLI in a block as

![1.storage_account](./screenshots/1.storage_account.PNG)
    

- Fill in the correct information in [terraform/environments/test/main.tf](terraform/environments/test/main.tf) and the corresponding modules.

- [Install Terraform Azure Pipelines Extension by Microsoft DevLabs.](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks)

- Create a new Service Connection by Project Settings >> Service connections >> New service connection >> Azure Resource Manager >> Next >> Service Principal (Automatic) >> Next >> Choose the correct subscription, and name such new service connection to Azure Resource Manager as `miroslavpetkovic`. This name will be used in azure-pipelines.yml and terraform pipeline.

![1.2.azure_resources](./screenshots/2.azure_resources.PNG)

  - Create a __terraform__ folder and inside another folder named __environments__, to store the different configurations of modules according to the environments you use.
  - Create another folder __project__ as a subfolder to environments to stimulate a type of environment.
  
     See the directory tree:
     
     
     ![3.terraform_tree_1](./screenshots/3.terraform_tree_1.PNG)
     
     ![3.terraform_tree_2](./screenshots/3.terraform_tree_2.PNG)
    
  - Deploying Terraform Infrastructure (Terraform resources) using Azure DevOps Pipelines:
    - Log in to your DevOps account and create a new project.
    - Initialize the Azure DevOps Repo to build the pipeline by __import a repository__ under __Repos__
    - Create a new Azure DevOps Build Pipeline
      - Click on Pipelines/pipelines on the left, then __Create Pipeline__. Select __Use the classic editor__
      - Then select the __Azure Repos Git__ option and select your project, repo and the branch, so __continue__
      - In __Select a template__, click on __Empty job__
      - Then click the plus sign (+) and add the __copy files__ task. Set the target folder as __$(build.artifactstagingdirectory)/Terraform__ and the display name as __Copy     Files__
      - Add another job with type __Publish Build Artifacts__ with defaults parameters
      - Now in the __Triggers__ tab, check __Enable continuous integration__ checkbox, and click on __Save & queue__, the __Save and run__. The pipeline is launched, and the status should be __Success__
 - Create an Azure DevOps Release Pipeline using the artifact generate on the build pipeline and a Stage task with these tasks:
   - Terraform installer
   - Terraform CLI (init, validate, plan and apply)
      - Adding the tasks:
        - First __Add an agent job__ (click on the 3 dots on the Build pipeline), so create a Stage task, add tasks to the agent job (search for Terraform). First task goes to “Terraform Installer”, click on __Add__ and it’s the same steps for the other tasks (Remember, to configure Terraform directory in Configuration Directory and the Backend Type), then Save the build pipeline.
        - On the __Pipeline__ menu, then __Release__ option. Click on the __New Pipeline__. In the __Select a template__, choose an __Empty job__ template.
        - Now click on __Add an Artifact__ button. In the page of __Add an artifact__, choose the __Build__ as __Source type__ to use the build pipeline created previously
        - Click on __Add__, then on __the lightning icon__ and enable the __CD trigger__. Rename the pipeline “azure-pipeline-release”, __Save__, then __OK__
        - Next is to configure the Stage, click on __Stage 1__ button to rename it to “Terraform”. Then click on __1job, 0 task__ link to configure the tasks. Click on the Agent job (+) sign and Add these tasks:
          - Terraform Installer
          - Terraform Init. In Terraform Init, set the __Backend Type__ to __self-configured__ (configured when you run ````configure_storage_account.sh````)
          - Terraform validate
          - Terraform plan
          - Terraform apply
          - In Terraform plan and apply, set the Environment Azure Subscription to your Subscription.
        - Click on __Save__, then on __Create release__, and it should show __Terraform Succeeded__ . Means that the resources I need it for the project is created, like the VM and the AppService.

![4.terraform_pipeline_1](./screenshots/4.terraform_pipeline_1.PNG)

![4.terraform_pipeline_5](./screenshots/4.terraform_pipeline_5.PNG)

![4.terraform_pipeline_6](./screenshots/4.terraform_pipeline_6.PNG)

![4.terraform_pipeline_2](./screenshots/4.terraform_pipeline_2.PNG)

![4.terraform_pipeline_3](./screenshots/4.terraform_pipeline_3.PNG)

![4.terraform_pipeline_4](./screenshots/4.terraform_pipeline_4.PNG)

Results of running terraform pipeline:

![5.terraform_pipeline_results_1](./screenshots/5.terraform_pipeline_results_1.PNG)

![5.terraform_pipeline_results_2](./screenshots/5.terraform_pipeline_results_2.PNG)

![5.terraform_pipeline_results_3](./screenshots/5.terraform_pipeline_results_3.PNG)

![5.terraform_pipeline_results_4](./screenshots/5.terraform_pipeline_results_4.PNG)

![5.terraform_pipeline_results_5](./screenshots/5.terraform_pipeline_results_5.PNG)

![5.terraform_pipeline_results_6](./screenshots/5.terraform_pipeline_results_6.PNG)



 ##  Execution of the tests duites**
    The tests suites will be executed to the Azure Devops, CI/CD pipeline.
    
 For the purouse of execution of Test Suites for:
        * Postman - runs during build stage
        * Selenium - runs on the linux VM in the deployment stage
        * JMeter - runs against the AppService in the deployment stage
  azure-pipelines.yaml was created.
  
  Results of implementation of testing pipelines are following:
  
  ![6.testing_pipeline_1](./screenshots/6.testing_pipeline_1.PNG)
  
  ![6.testing_pipeline_2](./screenshots/6.testing_pipeline_2.PNG)
  
  ![6.testing_pipeline_3](./screenshots/6.testing_pipeline_3.PNG)
  
  ![6.testing_pipeline_4](./screenshots/6.testing_pipeline_4.PNG)
    
  1. For Postman:

  Create a Regression Test Suite from the Starter APIs. Use the Publish Test Results task to publish the test results to Azure Pipelines.
  Create a Data Validation Test Suite from the Starter APIs.
  
   ![7.postman1](./screenshots/7.postman1.PNG)
   
   ![7.postman2](./screenshots/7.postman2.PNG)
   
   ![7.postman3](./screenshots/7.postman3.PNG)
   
   ![7.postman4](./screenshots/7.postman4.PNG)
 
2. For Selenium:

    * Create a UI Test Suite that adds all products to a cart, and then removes them.
    * Include print() commands throughout the tests so the actions of the tests can easily be determined. E.g. A login function might return which user is attempting to log in and whether or not the outcome was successful.
    * Deploy the UI Test Suite to the linux VM and execute the Test Suite via the CI/CD pipeline.

    ![8.Selenium](./screenshots/8.Selenium.PNG)

3. For JMeter:

    * Use the starter APIs to create two Test Suites. Using variables, reference a data set (csv file) in the test cases where the data will change.
    * Create a Stress Test Suite
    * Create a Endurance Test Suite
    * Generate the HTML report (non-CI/CD) IMPORTANT: Since the AppService is using the Basic/Free plan, start small (2 users max) and once you are ready for the final submission, use up to 30 users for a max duration of 60 seconds. The "Data Out" quota for the AppService on this plan is only 165 MiB.

  ![9.JMeter1](./screenshots/9.JMeter1.PNG)
  
  ![9.JMeter2](./screenshots/9.JMeter2.PNG)
  
  ![9.JMeter3](./screenshots/9.JMeter3.PNG)
  
  
4. Deploy FakeRestAPI artifact to the terraform deployed Azure App Service. The deployed webapp URL is https://mpetkovic-appservice.azurewebsites.net/ where mpetkovic-AppService is the Azure App Service resource name in small letters.

   ![10.FakeRestAPI1](./screenshots/10.FakeRestAPI1.PNG)
   
   ![10.FakeRestAPI2](./screenshots/10.FakeRestAPI2.PNG)
   
5. For Azure Monitor:

    * Configure an Action Group (email)
    * Configure an alert to trigger given a condition from the AppService
    * The time the alert triggers and the time the Performance test is executed ought to be very close.

    ![img-12](project-screenshots/azure-monitoring-data-out-metrics-capture.png)

    ![img-13](project-screenshots/azure-alert-capture.png)

    ![img-14](project-screenshots/azure-monitor-email-alert-capture.png)
    
           
   - **4. Alert**  
      * you will configure an alert on an Azure AppService. You’ll send some requests to cause the AppService to error, and trigger your alert.
       * Go to your appService in Micorsoft Azure, then look for **Monitoring** in the menu on the left hand side, then **Alerts**, click this.
       * Then make a **new Alert Rule**, check the resource first, then add a **Condition** and choose **HTTP 404**.
       * Set the threshold value to **1**, means whenever you got two HTTP 404 errors, the alert will trigger, then click **done**
       * Now create a new **Action Group** and call it for **email** (means, people who are interested in the alert). Then the **Action name** as HTTP 404 and the **Action Type** to **Email/SMS/Push/Voice** . Then tape your email, clico on ok and ok again.
       * so your alert rule name **HTTP 404 grather than 1**, **severity** to 1.
       ![alt text](https://github.com/devops21a/project_Ensuring_QR/blob/main/screenshots/alert_rule.png)
       * Back to your web browser, and create a few errors by givivng the URL of your AppService, and typing ````/feff````or some other random characters
       * And You should get an email (the alert will be triggered), like this:
       ![alt text](https://github.com/devops21a/project_Ensuring_QR/blob/main/screenshots/received_email_triggered_alert.png)
       
       Metrics:
       ![alt text](https://github.com/devops21a/project_Ensuring_QR/blob/main/screenshots/metric.png)
       
       Graphs of resource:
       ![alt text](https://github.com/devops21a/project_Ensuring_QR/blob/main/screenshots/graphs_of_resource.png)
       
     * **About Log Analytics**
       * I made a worksapce (finalprojectworkspace) following the steps [here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-sources-custom-logs)
       * Then I installed the Linux agent using a wrapper script form [here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-linux#install-the-agent-using-wrapper-script)
       * Then I uploaded a sample log (**selenium/login.log**) with a new line as delimeter following the [docs](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-sources-custom-logs). I changed the permissions of ````login.log```` to 755.
       * Added the log path. In my case **/home/adminuser/azagent/_work/1/LoginTestSuite/selenium/login.log** and provided a name for the log "FinalTest"
       * I queried mu custom Log **FinalTest_CL**
       * But, I don't get returned  the records. I just get **No results found**
       
       ![alt text](https://github.com/devops21a/project_Ensuring_QR/blob/main/screenshots/no_results_found.png)
       * I tried many times to get the records by making new worksapce, new log-file and even I tried on another VM. But I keep getting **Nothing**.
       * I tried the trouble shooting, using the **Log Analytics agent for Linux log file**: ````sudo cat /var/opt/microsoft/omsagent/<workspace id>/log/omsagent.log````
       * I found these two incomprehensible lines:  
       ![alt text](https://github.com/devops21a/project_Ensuring_QR/blob/main/screenshots/linux_agent_log.png)
       
       * I searched almost the world to understand why I am not getting the records.
       


## References:
 * https://azuredevopslabs.com/labs/vstsextend/terraform/ 
 * https://gmusumeci.medium.com/deploying-terraform-infrastructure-using-azure-devops-pipelines-step-by-step-d58b68fc666d
 * https://www.geeksforgeeks.org/logging-in-python/
 * https://linuxhint.com/chrome_selenium_headless_running/
 * https://medium.com/@ganeshsirsi/how-to-configure-postman-newman-api-tests-in-azure-devops-or-tfs-and-publish-html-results-caf60a25c8b9
 * https://learning.postman.com/docs/running-collections/using-newman-cli/command-line-integration-with-newman/
 * https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys
