# 🚦 GCP Databricks Project

---
## 🟡 Set up databricks free account in GCP Free Tier

## 🟢 Dev Environment Setup
- **Create Dev Project in GCP** → `project-dev-date`  
- **Create Dev Bucket in GCS** → `bkt-dev-date`  
  - **Folders**  
    1. 📂 **landing**  
       - raw_traffic  
       - raw_roads  
    2. 📂 **checkpoints**  
    3. 📂 **medallion**  
       - bronze  
       - silver  
       - gold  

- **Create Dev Workspace in Databricks** → `dbx-dev-ws`  
- **Create Catalog** → `dev_catalog`  
- **Create Dev Storage Credential** → `bkt-dev-creds`  

- **Create External Locations** (5)  
  - landing_dev  
  - checkpoints_dev  
  - bronze_dev  
  - silver_dev  
  - gold_dev  

- **Create Databricks Cluster** → `dev-cluster`  

---

## 🟡 Schema & Table Creation
- **Schemas (01)**  
  - bronze  
  - silver  
  - gold  

- **Tables (02)**  
  - raw_roads  
  - raw_traffic  

---

## 🟠 ETL Pipeline (Landing → Medallion Architecture)

### Landing → Bronze (03)
- Use **Autoloader in Batch Mode**  
- Upload sample data → raw_traffic & raw_roads  
- Execute the notebook  
- Test by adding one more file and re-executing  

---

### Bronze → Silver (04,05)
- Use **Structured Streaming in Batch Mode**  
- Execute the notebook  
- Test by adding one more file and re-executing  

---

### Commons Notebook
- Store **common variables**  
- Store **common functions** used in transformations  

---

### Silver → Gold (06)
- Apply transformations as per reporting requirements  
- Write results to **Gold Tables**  

---

## 🔵 Orchestration
- Update notebooks to job-ready format  
- Create **Job** → `ETL Workflow`  
  - **Tasks**  
    - Task1 → load_to_bronze (03)  
    - Task2 → silver_traffic (04)  
    - Task3 → silver_roads (05)  
    - Task4 → gold (06)  

- **Add Trigger**  
  - File Arrival → `landing/traffic` folder  
    - Notification for success/failure  
    - Upload sample file for testing  
  - Schedule → For `roads` dataset (monthly updates)  

---

## 🟣 UAT Environment Setup
- **Create UAT Project in GCP** → `project-uat-date`  
- **Create UAT Bucket in GCS** → `bkt-uat-date`  
  - **Folders**  
    1. landing → raw_traffic, raw_roads  
    2. checkpoints  
    3. medallion → bronze, silver, gold  

- **Create UAT Workspace in Databricks** → `gcp-dbx-uat`  
- **Create Catalog** → `uat_catalog`  
- **Create Storage Credential** → `bkt-uat-creds`  

- **Create External Locations (5)**  
  - landing_uat  
  - checkpoints_uat  
  - bronze_uat  
  - silver_uat  
  - gold_uat  

- **Create Databricks Cluster** → `uat-cluster`  

---

## 🟤 GitHub Integration
- Create repo → `gcp-dbx-traffic`  
- Integrate GitHub with Databricks  
  - Settings → Linked accounts → Add Git Integration → Sign-in  
  - Workspace → Repos → Add Git Folder → `main` branch → success  

- **Branching Strategy**  
  - Dev → UAT → PRD (main)  

---

## 🟢 Dev → UAT → PRD Workflow
### Dev
- Development in **dev branch**  
- Clone project → commit & push  
- Update pipeline with Git URL/branch + notebook path  
- Run & test pipeline  

### UAT
- Create PR → merge (if no conflicts)  
- In UAT workspace → add Git folder → switch to `uat` branch  
- Execute codes with parameter `(uat)`  
- Create ETL workflow using Git notebooks  

### PRD
- Repeat same process for **prd** environment  

---
