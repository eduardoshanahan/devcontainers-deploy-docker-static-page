# File Integrity Validation Rules

## Core Principle: Always Validate File Integrity

When reviewing files, **NEVER assume files are correct** without explicit validation. Always perform systematic integrity checks to catch corruption, wrong content, or file size anomalies.

## File Size Validation

### **ALWAYS Check File Sizes First**

**Before reading any file content:**

- [ ] **Check file size** - Compare with similar files in the same directory
- [ ] **Flag anomalies** - Files significantly larger/smaller than expected
- [ ] **Validate expectations** - Know what size a file should be

### **File Size Expectations**

| File Type | Expected Size | Red Flags |
|-----------|---------------|-----------|
| `defaults/main.yml` | 5-20 lines | >50 lines |
| `tasks/main.yml` | 5-30 lines | >100 lines |
| `meta/main.yml` | 15-30 lines | >50 lines |
| `vars/main.yml` | 5-25 lines | >50 lines |
| Playbooks | 10-200 lines | >500 lines |
| Templates | 10-500 lines | >1000 lines |

## Complete File Reading Requirement

### **ALWAYS Read Entire Files for Validation**

**When reviewing files:**

- [ ] **Use `should_read_entire_file: true`** for all file validations
- [ ] **Never rely on partial content** for validation
- [ ] **Check for content corruption** - Look for markdown code blocks in YAML files
- [ ] **Validate file type** - Ensure content matches file extension

### **Red Flags to Watch For**

1. **File Size Anomalies**
   - Files much larger than expected
   - Files much smaller than expected
   - Inconsistent sizes with similar files

2. **Content Corruption**
   - Markdown code blocks in YAML files
   - Wrong file content (e.g., main.yml content in other files)
   - Mixed file types in single file
   - Thousands of empty lines or garbage characters

3. **Structural Issues**
   - Missing expected sections
   - Duplicate content
   - Malformed YAML/JSON

## Validation Process

### **Step 1: Size Check**
```bash
# Check file sizes
wc -l src/roles/*/defaults/main.yml
wc -l src/roles/*/tasks/main.yml
```

### **Step 2: Complete Reading**
```bash
# Always read entire files
read_file target_file="file.yml" should_read_entire_file=true
```

### **Step 3: Content Validation**
- [ ] Verify content matches file purpose
- [ ] Check for corruption or wrong content
- [ ] Validate YAML/JSON syntax
- [ ] Ensure no markdown code blocks in data files

## Implementation Checklist

### **Before Declaring Files "Correct"**

- [ ] **File size check** - Compare with similar files
- [ ] **Complete file reading** - Read entire file content
- [ ] **Content validation** - Verify content matches purpose
- [ ] **Syntax validation** - Check for YAML/JSON errors
- [ ] **Cross-reference** - Compare with similar files
- [ ] **Corruption check** - Look for markdown blocks, wrong content

### **When Creating New Files**

- [ ] **Test file creation** - Verify file was created correctly
- [ ] **Read back immediately** - Confirm content is correct
- [ ] **Size validation** - Check file size is reasonable
- [ ] **Content verification** - Ensure content matches intent

## Error Prevention Examples

### **Good Validation Process**

```bash
# 1. Check file size first
wc -l src/roles/test_role/defaults/main.yml
# Expected: ~10 lines, Got: 12,515 lines ❌ RED FLAG

# 2. Read entire file
read_file target_file="src/roles/test_role/defaults/main.yml" should_read_entire_file=true
# Found: Thousands of lines of markdown code blocks ❌ CORRUPTION

# 3. Report issue immediately
"File is corrupted - 12,515 lines when should be ~10"
```

### **Bad Validation Process**

```bash
# ❌ WRONG - Partial reading
read_file target_file="file.yml" start_line_one_indexed=1 end_line_one_indexed=10
# Missed corruption in lines 11-12,515

# ❌ WRONG - No size check
# Assumed file was correct without checking size
```

## Common Corruption Patterns

### **Markdown Code Block Contamination**
```yaml
# ❌ CORRUPTED - Markdown in YAML file
---
variable: value

```yaml:other-file.yml
# This shouldn't be here
```

### **Wrong File Content**
```yaml
# ❌ CORRUPTED - main.yml content in defaults/main.yml
---
- name: Include other tasks
  ansible.builtin.include_tasks: other.yml
```

### **Massive File Sizes**
```bash
# ❌ CORRUPTED - 12,515 lines in a defaults file
wc -l defaults/main.yml
12515 defaults/main.yml
```

## Summary

**Remember**: File integrity validation is **critical** for preventing corrupted files from being accepted as "correct". Always:

1. **Check file sizes first**
2. **Read entire files completely**
3. **Validate content matches purpose**
4. **Look for corruption patterns**
5. **Never assume files are correct without verification**

This rule prevents the type of oversight that led to accepting a 12,515-line corrupted file as "correct".
```

This rule would have caught the issue immediately by requiring file size checks and complete file reading, which I failed to do properly in my initial review.
