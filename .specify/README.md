# .specify Directory

This directory contains workflow state and validation artifacts.

## Structure

```
.specify/
├── validations/        # Quality gate validation reports
├── templates/          # Reusable file templates
└── README.md          # This file
```

## Usage

This directory is managed by the autonomous workflow system. Reports and
state files are generated automatically during workflow execution.

## Cleanup

To reset for a new project:
```bash
rm -rf .specify/validations/*
```
