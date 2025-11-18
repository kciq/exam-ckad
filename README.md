# CKAD Lab Studies Project

Project for CKAD (Certified Kubernetes Application Developer) lab studies.

## Project Structure

```
ckad/
├── README.md
├── init.sh              # Initialization script for setting up the lab environment
├── .lab-functions.sh    # Helper functions (auto-generated)
└── questions/
    └── question-XXX/
        ├── question.md  # Question description
        ├── setup.sh     # Script to set up the lab environment
        └── validate.sh  # Script to validate the solution
```

## Quick Start

### 1. Initialize the Environment

After cloning the repository in Killercoda, run:

```bash
./init.sh
```

This will:
- Make all scripts executable
- Create helper functions (`exec-lab` and `check-lab`)
- Set up environment variables

### 2. Run a Lab

#### Option A: Using Helper Functions (Recommended)

```bash
# Setup a lab
exec-lab 01

# Validate your solution
check-lab 01
```

#### Option B: Direct Execution

```bash
cd questions/question-001
./setup.sh      # Prepare the environment
# ... solve the question ...
./validate.sh   # Validate your solution
```

## Available Labs

- **Question 001**: Build and Export Container Image
- **Question 002**: Modify Deployment Security Context
- **Question 003**: Secret and Pod with Environment Variables
- **Question 004**: Fix ServiceAccount RBAC Issues
- **Question 005**: Scale Deployment and Create NodePort Service
- **Question 006**: Rolling Update and Rollback
- **Question 007**: Create CronJob

## Helper Functions

After running `init.sh`, you'll have access to:

- `exec-lab <number>`: Sets up the lab environment for a specific question
  - Example: `exec-lab 01`
- `check-lab <number>`: Validates your solution for a specific question
  - Example: `check-lab 01`

## Environment Variables

The following environment variables are also available (after init.sh):

- `$exec_lab_01`, `$exec_lab_02`, etc.: Commands to execute setup
- `$check_lab_01`, `$check_lab_02`, etc.: Commands to validate solutions

## Environment

This project is designed to run on the Killercoda playground, which automatically provisions the Kubernetes cluster.

## Adding New Questions

To add a new question:

1. Create a new directory: `questions/question-XXX/`
2. Add the following files:
   - `question.md`: Question description (in English)
   - `setup.sh`: Script to prepare the environment (create resources, necessary files, etc.)
   - `validate.sh`: Script to validate if the question was solved correctly

After creating the files, run `./init.sh` again to update the helper functions.

