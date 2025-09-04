# -------------------> GCP Databricks Project <---------------------

## Databricks Setup

- **Set up Databricks free account** in **GCP Free Tier**

- **Go to Databricks account console**
  - Create **UC Metastore** in `us-central1` region → **gcp-dbx-ms**
  - Create two workspaces:
    - **Dev** → `dbx-dev-ws` (us-central1)
    - **UAT** → `dbx-uat-ws` (us-central1)
  - Assign workspaces to the metastore

---

## Setup Dev Environment

- **Create Dev Project** in GCP → `project-dev-date`
- **Create Dev Bucket** in GCS → `bkt-dev-date`
  - **Folders**:
    1. `landing`
       - `raw_traffic`
       - `raw_roads`
    2. `checkpoints`
    3. `medallion`
       - `bronze`
       - `silver`
       - `gold`

- **Create Catalog** → `dev_catalog`
- **Create Dev Storage Credentials** → `bkt-dev-creds`
- **Create 5 External Locations** to access GCS:
  - `landing_dev`
  - `checkpoints_dev`
  - `bronze_dev`
  - `silver_dev`
  - `gold_dev`

- **Create Databricks Cluster** → `dev-cluster`

---

### Development Steps

1. **Create Schemas Dynamically (01)**
   - bronze  
   - silver  
   - gold  

2. **Create Tables Dynamically (02)**
   - raw_roads  
   - raw_traffic  

3. **Landing to Bronze (03)**
   - Use **Autoloader** in batch mode  
   - Upload sample data to `raw_traffic` and `raw_roads`  
   - Execute the notebook  
   - Add one more file for testing and re-execute (later will schedule this)  

4. **Bronze to Silver (04,05)**
   - Use **Structured Streaming** in batch mode  
   - Execute the notebook  
   - Add one more file for testing and re-execute (later will schedule this)  

5. **Commons Notebook**
   - Store common variables and functions used in transformations  

6. **Silver to Gold (06)**
   - Apply reporting requirements and transformations  
   - Write to **Gold tables**  

---

### Orchestration

- Update notebooks to **job ready**
- Create a job → **ETL Workflow**
  - **Task1** → load_to_bronze (03)
  - **Task2** → silver_traffic (04)
  - **Task3** → silver_roads (05)
  - **Task4** → gold (06)

- **Add Triggers**
  - **File Arrival** (traffic data arrives frequently)
    - Select the `landing/traffic` folder
    - Add notification for success/failure
    - Upload a sample file for testing
  - **Schedule** (for roads data, monthly updates)

---

## Setup GitHub

- Create **new public repo** → `gcp-dbx-traffic`
- Integrate repo with each Databricks:
  - Settings → Linked Accounts → Add Git Integration → Link Git Account → Sign-In
  - Workspace → Repos → Add Git Folder → Main branch → Success
  - Create **dev**, **uat** branches

- **Project Flow**:  
  `dev` → `uat` → `prd (main)`

---

## Back to Dev

- All development is done in **Dev**
- Clone project code → **commit & push**
- Update pipeline to Git (url, branch) for all tasks and choose notebook path
- Run and test pipeline → **Success**

---

## Setup UAT Environment

- **Create UAT Project** in GCP → `project-uat-date`
- **Create UAT Bucket** in GCS → `bkt-uat-date`
  - **Folders**:
    1. `landing`
       - `raw_traffic`
       - `raw_roads`
    2. `checkpoints`
    3. `medallion`
       - `bronze`
       - `silver`
       - `gold`

- **Create Catalog** → `dev_catalog`
- **Create UAT Storage Credentials** → `bkt-uat-creds`
- **Create 5 External Locations** to access GCS:
  - `landing_uat`
  - `checkpoints_uat`
  - `bronze_uat`
  - `silver_uat`
  - `gold_uat`

- **Create Databricks Cluster** → `uat-cluster`

---

## UAT Process

- If everything runs fine in **Dev**, move to **UAT**
- Create PR and merge (if no conflicts)
- In Databricks UAT workspace → Add Git folder → Switch to **uat branch**
- Execute all codes one by one with parameter `(uat)`
- Create ETL Workflow and choose notebooks from Git

---

## Create PRD Environment

- Setup PRD similar to **Dev** and **UAT**

---

✅ **End of Setup**
