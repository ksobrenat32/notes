# Erpnext notes

I mainly use the Docker installation of ERPNext, so these notes are focused on that setup.

## General commands for Frappe/ERPNext with Docker

### Get a python prompt inside a running container

```sh
sudo docker exec -it container_name_backend bench --site frontend console
```

### When updating

If the image is updated, the database needs to be migrated.

```sh
sudo docker exec -it container_name_backend bench --site frontend migrate
```

### When frontend is not loading properly

```sh
sudo docker exec -it container_name_backend bench --site frontend clear-cache
sudo docker exec -it container_name_backend bench --site frontend clear-website-cache
sudo docker exec -it container_name_redis_queue redis-cli flushall
sudo docker exec -it container_name_redis_cache redis-cli flushall
```

### Change variant template

Sometimes in ERPNext, an item variant may be incorrectly linked to the wrong template. The following Python scripts can be used within the Frappe framework to correct this issue.

**If the item has no links:**

```python
def update_variant_template(variant_to_fix, correct_template):
    # Fetch the variant document
    doc = frappe.get_doc("Item", variant_to_fix)

    # Update the variant_of field
    doc.variant_of = correct_template

    # Save the changes
    doc.save()

    # Commit to apply changes to the database
    frappe.db.commit()

    print(f"Updated Item {variant_to_fix}: Now a variant of {correct_template}")
```

**If the item has links and cannot be changed directly:**

```python
def clone_variant_fix_template(old_variant, correct_template):
    # Fetch existing variant
    old_doc = frappe.get_doc("Item", old_variant)

    # Generate a new unique item code
    new_item_code = make_autoname(f"{old_variant}-.#####")

    # Create a new variant with the correct template
    new_doc = frappe.copy_doc(old_doc)
    new_doc.variant_of = correct_template
    new_doc.item_code = new_item_code  # Assign a unique item code
    new_doc.insert()

    # Deactivate old variant to prevent further usage
    old_doc.disabled = 1
    old_doc.save()

    # Commit to apply changes to the database
    frappe.db.commit()

    print(f"Created new variant {new_doc.name} ({new_item_code}) under {correct_template} and disabled {old_variant}.")
```

**Example usage:**

```python
# Update a single variant
update_variant_template("variant_code", "template_code")

# Clone a variant and fix the template
clone_variant_fix_template("variant_code", "template_code")
```


