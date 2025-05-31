# Project Issues & Improvements Canvas

## 🔥 **Critical Priority (Fix First)**

### 1. **Duplicated IP Detection Logic**
**Impact:** High | **Effort:** Medium
- **Location:** `wait-for-ssh.sh`, `verify-deployment.sh`, `deploy.sh`
- **Issue:** Same complex IP detection function copied 3 times
- **Risk:** Inconsistent behavior, maintenance nightmare
- **Fix:** Create `lib/common.sh` with shared `get_vm_id()` function

### 2. **Redundant Terraform Provider Blocks**
**Impact:** Medium | **Effort:** Low
- **Location:** `main.tf` and `vm-module/vm.tf`
- **Issue:** Provider requirements duplicated
- **Fix:** Remove provider block from `vm-module/vm.tf` (not needed in modules)

### 3. **Fragile Relative Paths**
**Impact:** Medium | **Effort:** Low
- **Location:** `run-ansible.sh`, multiple scripts
- **Issue:** `cd ../ansible` breaks if script run from wrong location
- **Fix:** Use `cd "$(dirname "$0")/../ansible"` pattern

## 🚨 **High Priority (Next Sprint)**

### 4. **Missing Error Handling**
**Impact:** High | **Effort:** Medium
- **Location:** All bash scripts
- **Issue:** Scripts don't handle failures gracefully
- **Fix:** Add `set -euo pipefail` and proper error traps

### 5. **No Input Validation**
**Impact:** Medium | **Effort:** Low
- **Location:** IP detection functions
- **Issue:** No validation of extracted IP addresses
- **Fix:** Add IP format validation function

### 6. **Inconsistent Logging**
**Impact:** Medium | **Effort:** Low
- **Location:** All scripts
- **Issue:** Mixed echo/logging approaches
- **Fix:** Standardize logging functions (info, warn, error)

## 📋 **Medium Priority (Backlog)**

### 7. **Missing Documentation Files**
**Impact:** Medium | **Effort:** Low
- **Missing:** `terraform.tfvars.example`, `CONTRIBUTING.md`
- **Issue:** New users don't know how to configure
- **Fix:** Create example files and setup documentation

### 8. **No Health Check Strategy**
**Impact:** Medium | **Effort:** Medium
- **Location:** Docker container, service monitoring
- **Issue:** No automated health monitoring
- **Fix:** Add Docker HEALTHCHECK, monitoring endpoints

### 9. **Hardcoded Configuration Values**
**Impact:** Medium | **Effort:** Medium
- **Location:** Multiple files (IP ranges, timeouts, paths)
- **Issue:** Values scattered throughout codebase
- **Fix:** Centralize configuration in variables/config files

### 10. **No Local Development Environment**
**Impact:** Low | **Effort:** Medium
- **Missing:** `docker-compose.yml` for local testing
- **Issue:** Can't test Flask app without full deployment
- **Fix:** Create local development setup

## 🔧 **Low Priority (Nice to Have)**

### 11. **Improve Script Robustness**
**Impact:** Low | **Effort:** Medium
- **Location:** All scripts
- **Issue:** No signal handling, cleanup on exit
- **Fix:** Add trap handlers for cleanup

### 12. **Add Script Testing**
**Impact:** Low | **Effort:** High
- **Missing:** Unit tests for bash functions
- **Issue:** No way to verify script behavior
- **Fix:** Add bats-core testing framework

### 13. **Optimize Docker Image**
**Impact:** Low | **Effort:** Low
- **Location:** `src/Dockerfile`
- **Issue:** Single-stage build, could be smaller
- **Fix:** Multi-stage build, alpine base image

### 14. **Add Backup Strategy**
**Impact:** Low | **Effort:** Medium
- **Missing:** Config file backup/restore
- **Issue:** No way to recover from config corruption
- **Fix:** Add backup scripts and procedures

## 🎯 **Code Quality Issues**

### 15. **Unused Variables and Functions**
**Impact:** Low | **Effort:** Low
- **Location:** Various files
- **Issue:** Some defined variables never used
- **Fix:** Clean up dead code

### 16. **Inconsistent Naming Conventions**
**Impact:** Low | **Effort:** Low
- **Location:** Variables, files, functions
- **Issue:** Mixed snake_case, camelCase, kebab-case
- **Fix:** Standardize on convention (suggest snake_case)

### 17. **Long Functions**
**Impact:** Low | **Effort:** Medium
- **Location:** `deploy.sh`, IP detection functions
- **Issue:** Some functions doing too many things
- **Fix:** Break into smaller, focused functions

## 📊 **Technical Debt**

### 18. **No Configuration Validation**
**Impact:** Medium | **Effort:** Medium
- **Location:** JSON config files
- **Issue:** Invalid JSON could break services
- **Fix:** Add JSON schema validation

### 19. **No Rollback Strategy**
**Impact:** Medium | **Effort:** High
- **Location:** Deployment process
- **Issue:** No way to rollback failed deployments
- **Fix:** Implement blue-green or rollback mechanisms

### 20. **Manual Secret Management**
**Impact:** Low | **Effort:** High
- **Location:** Config files (for production use)
- **Issue:** Secrets in plain text (okay for homelab)
- **Fix:** Integrate with HashiCorp Vault or similar

## 🚀 **Enhancement Opportunities**

### 21. **Add Monitoring Dashboard**
**Impact:** Low | **Effort:** High
- **Missing:** Prometheus + Grafana setup
- **Benefit:** Real-time service monitoring
- **Fix:** Add monitoring stack to deployment

### 22. **Implement CI/CD Pipeline**
**Impact:** Low | **Effort:** High
- **Missing:** Automated testing and deployment
- **Benefit:** Catch issues early, automated deploys
- **Fix:** Add GitHub Actions or similar

### 23. **Add Configuration Hot-Reload**
**Impact:** Low | **Effort:** Medium
- **Location:** Flask application
- **Issue:** Must restart service to reload configs
- **Fix:** Add file watching and hot-reload capability

---

## 📋 **Implementation Roadmap**

### **Week 1: Quick Wins**
- Fix duplicated provider blocks (#2)
- Fix relative paths (#3)
- Add input validation (#5)

### **Week 2: Core Stability**
- Consolidate IP detection (#1)
- Add error handling (#4)
- Standardize logging (#6)

### **Week 3: Documentation & Testing**
- Create example files (#7)
- Add health checks (#8)
- Test robustness improvements

### **Month 2: Advanced Features**
- Local development environment (#10)
- Configuration centralization (#9)
- Backup strategy (#14)

---

*Priority based on: Impact to stability, Learning value, Implementation effort*