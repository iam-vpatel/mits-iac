Below is a proposal for integrating **Ansible Vault** into your existing project to safely store your controller and Webex tokens (and any other secrets). This will:

1. Create a top-level `ansible/vault.yml` encrypted file
2. Add an `ansible.cfg` so Ansible knows how to find your vault password
3. Modify your playbook to load the vault vars
4. Update your runbook with the steps to manage the vault

---

## 1. Add an encrypted Vault file

Create `ansible/vault.yml` (initially unencrypted):

```yaml
# ansible/vault.yml
---
ansible_controller_token: YOUR_CONTROLLER_TOKEN
webex_bearer_token: YOUR_WEBEX_TOKEN
```

Then encrypt it **in-place**:

```bash
cd aim-infra-terransible/ansible
ansible-vault encrypt vault.yml
```

You’ll be prompted for a vault password; keep that somewhere safe (e.g. `~/.vault_pass.txt`, see step 2).

---

## 2. Configure Ansible to use your Vault password

Create `ansible/ansible.cfg`:

```ini
[defaults]
vault_password_file = ~/.vault_pass.txt
```

Put your vault password in `~/.vault_pass.txt` and protect it:

```bash
chmod 600 ~/.vault_pass.txt
```

---

## 3. Modify your playbook to load the Vault vars

In `ansible/playbooks/nonfed/siteminder/siteminder.yml`, at the top add:

```yaml
---
- name: Install SiteMinder
  hosts: role_siteminder
  become: yes

  vars_files:
    - ../../../vault.yml # loads ansible_controller_token & webex_bearer_token

  tasks:
    - name: Ping EC2 hosts
      ping:

    - name: Install required packages
      yum:
        name:
          - unzip
          - httpd
        state: present

    - name: Notify Webex (Success)
      uri:
        url: "https://webexapis.com/v1/messages"
        method: POST
        headers:
          Authorization: "Bearer {{ webex_bearer_token }}"
          Content-Type: "application/json"
        body: |
          {
            "roomId": "{{ lookup('env','WEBEX_ROOM_ID') }}",
            "text": "✅ SiteMinder installed on {{ inventory_hostname }}"
          }
        body_format: json
```

Now the playbook will decrypt `vault.yml` at runtime (using your `~/.vault_pass.txt`) and make `webex_bearer_token` available.

---

## 4. Update your runbook

Add a **Vault** section to `runbook.md`:

````markdown
### Managing Secrets with Ansible Vault

1. **Create or edit** the vault file:
   ```bash
   cd ansible
   ansible-vault edit vault.yml
   ```
````

2. **Run playbooks** normally—Ansible will prompt for the vault password unless:

   - You’ve configured `vault_password_file` in `ansible/ansible.cfg`, or
   - You supply `--vault-password-file ~/.vault_pass.txt` on the CLI.

3. **Rotate secrets** by editing `vault.yml` and saving; commit the updated encrypted file.

4. **Secure your vault password** (`~/.vault_pass.txt`)—do _not_ check it into VCS.

```

---

### Final Project Snippet

```

aim-infra-terransible/
├── ansible/
│ ├── ansible.cfg ← points at your vault password file
│ ├── vault.yml ← encrypted with ansible-vault
│ ├── inventory/
│ └── playbooks/
│ └── nonfed/
│ └── siteminder/
│ └── siteminder.yml ← now loads vault.yml

```

With these changes, **no plain-text secrets** live in your repo anymore—only the encrypted `vault.yml`. Whenever Ansible runs (either on your laptop or via your bootstrap UserData script), it will decrypt the tokens as needed to send Webex messages or authenticate with your Controller.
```
