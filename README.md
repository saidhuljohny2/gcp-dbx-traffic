- project introduction
- project architecture
- understanding the datasets
- databricks free account on GCP Free Tier

----------------------> Project Implementation Guide <---------------------------

Databricks Setup:
	- create two projects in gcp 
		- dev (project-dev-9122025)
		- uat (project-uat-9122025)
		
	- go to databricks account console
		- create uc metastore (gcp-dbx-metastore)
			- region(us-central1)
			- gcs bucket
		- create two workspaces
			- dev (project-dev-9122025)
			- uat (project-uat-9122025)
		- assign the workspaces to the uc metastore
		
- setup infra dev env :
	- create dev gcs bucket 
	- setup folders
		- landing
			- raw_traffic
			- raw_roads
		- checkpoints
		- medallion
			- bronze
			- silver
			- gold
	- Create Catalog → dev_catalog
	- Create Dev Storage Credentials - (bkt-dev-creds)
	- Create 5 External Locations to access GCS:
		- landing_dev
		- checkpoints_dev
		- bronze_dev
		- silver_dev
		- gold_dev
	- create databricks cluster (dev-cluster)
	
- development steps :
	- create schemas dynamically (01-NB)
		- bronze 
		- silver 
		- gold
	- creating bronze tables dynamically (02-NB)
		- raw_roads
		- raw_traffic
	- load to bronze (03-NB) (autoloader)
		- landing to bronze tables
	- silver_traffic_transaformation (04-NB) (structured streaming)
		- bronze ---> clean, transform ---> silver tables
	- silver_roads_transaformation (05-NB) (structured streaming)
		- bronze ---> clean, transform ---> silver tables
	- gold_transformations (06-NB) (structured streaming)
		- silver ---> aggregations ---> gold tables 
		- gold tables 
			- gold_traffic
			- gold_roads
			- traffic volume by year 
			- traffic by region 
			- road usage statistics
			- ev adoption trend

- workflow orchestration :
	- ensure all your notebooks are production ready
	- create workflow (ETL workflow) --> parameter => (env = dev)
		- task1 : load to bronze (03-NB)
		- task2 : silver_traffic_transaformation (04-NB)
		- task3 : silver_roads_transaformation (05-NB)
		- task4 : gold_transformations (06-NB)
	- trigger
		- file arrival : raw_traffic gcs location 
		
- setup github : (dev --> uat --> prd)
	- go to github and create account 
	- create a repo : (gcp-dbx-traffic)
	- integrate github with databricks 
	- create branches 
		- main (prd)
		- dev 
		- uat
	
- back to dev :
	- move dev code to dev branch 
	- commit and push the changes (warning : install databricks on top of github)
	- Update pipeline to Git (url, branch) for all tasks and choose notebook path
	- run and test pipline --> success
	
- Setup Infra UAT env :
	- go to uat project in gcp
	- create uat bucket in gcs --> (bkt-uat-9142025)
		- landing 
			- raw_traffic
			- raw_roads
		- checkpoints
		- medallion
			- bronze
			- silver
			- gold
	- create storage Credentials --> (bkt-uat-creds)
	- Create 5 External Locations to access GCS:
		- landing_uat
		- checkpoints_uat
		- bronze_uat
		- silver_uat
		- gold_uat
	- create uat catalog --> uat_catalog
	- create cluster in uat env ---> uat-cluster
	
- UAT workflow orchestration :
	- all the code Implementation done in dev environment ---> dev branch 
	- integrate github with databricks uat workspace
	- create pull request (PR) to move the code from dev ---> uat 
		- go to github 
		- create pr --> successful ---> you have code on UAT branch
		- pull the changes in uat branch in databricks workspace
	- create schemas dynamically (01-NB)
		- bronze 
		- silver 
		- gold
	- creating bronze tables dynamically (02-NB)
		- raw_roads
		- raw_traffic
	- create workflow :
		- ensure all your notebooks are production ready
		- create workflow (ETL workflow) --> parameter => (env = uat)
			- task1 : load to bronze (03-NB)
			- task2 : silver_traffic_transaformation (04-NB)
			- task3 : silver_roads_transaformation (05-NB)
			- task4 : gold_transformations (06-NB)
		- trigger
			- file arrival : raw_traffic gcs location 
		- test run ---> success
		
- PRD setup : (assignment)
	- similar to dev and uat 
		- create project in gcp 
		- create prd workspace and attach to metastore
		- setup prd infra : gcs, ext loc, storage creds, catalog, cluster
		- create PR (uat ---> prd)
			- all the code in prd 
		- start creating schemas and bronze tables 
		- create workflow (ETL workflow)
			--> tasks --> choose notebooks from git --> parameter (env=prd)
		- run and test the pipeline with sample data 
		---> success
		
-- successfully completed the --> end to end databricks project on GCP

--> doubts : 
	SHAIK SAIDHUL (linkedIn)
	7305101711 (Whatsapp)

--> project --> resume --> apply --> interviews ---> all the best for your endeavours
