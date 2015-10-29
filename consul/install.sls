{% from "consul/map.jinja" import consul with context %}

unzip:
  pkg.installed

/usr/local/bin:
  file.directory:
    - makedirs: True

# Create consul user
consul-user:
  group.present:
    - name: consul
  user.present: 
    - name: consul
    - createhome: false
    - system: true
    - groups:
      - consul
    - require:
      - group: consul

# Create directories
consul-config-dir:
  file.directory:
    - name: /etc/consul.d
    - user: consul
    - group: consul

consul-runtime-dir:
  file.directory:
    - name: /var/consul
    - user: consul
    - group: consul

consul-data-dir:
  file.directory:
    - name: /usr/local/share/consul
    - user: consul
    - group: consul
    - makedirs: 

# Install agent
consul-download:
  file.managed:
    - name: /tmp/{{ consul.version }}_linux_amd64.zip
    - source: https://dl.bintray.com/mitchellh/consul/{{ consul.version }}_linux_amd64.zip
    - source_hash: sha1={{ consul.hash }}
    - unless: test -f /usr/local/bin/consul-{{ consul.version }}

consul-extract:
  cmd.wait:
    - name: unzip /tmp/{{ consul.version }}_linux_amd64.zip -d /tmp
    - watch:
      - file: consul-download

consul-install:
  file.rename:
    - name: /usr/local/bin/consul-{{ consul.version }}
    - source: /tmp/consul
    - require:
      - file: /usr/local/bin
    - watch:
      - cmd: consul-extract

consul-clean:
  file.absent:
    - name: /tmp/{{ consul.version }}_linux_amd64.zip
    - watch:
      - file: consul-install

consul-link:
  file.symlink:
    - target: consul-{{ consul.version }}
    - name: /usr/local/bin/consul
    - watch:
      - file: consul-install

# Install UI
consul-ui-download:
  file.managed:
    - name: /tmp/{{ consul.ui_version }}_web_ui.zip
    - source: https://dl.bintray.com/mitchellh/consul/{{ consul.ui_version }}_web_ui.zip
    - source_hash: sha1={{ consul.ui_hash }}
    - unless: test -d /usr/local/share/consul/ui-{{ consul.ui_version }}

consul-ui-extract:
  cmd.wait:
    - name: unzip /tmp/{{ consul.ui_version }}_web_ui.zip -d /tmp/
    - watch:
      - file: consul-ui-download

consul-ui-install:
  file.rename:
    - name: /usr/local/share/consul/ui-{{ consul.ui_version }}
    - source: /tmp/dist
    - require:
      - file: /usr/local/share/consul
    - watch:
      - cmd: consul-ui-extract

consul-ui-clean:
  file.absent:
    - name: /tmp/{{ consul.ui_version }}_web_ui.zip
    - watch:
      - file: consul-ui-install

consul-ui-link:
  file.symlink:
    - target: ui-{{ consul.ui_version }}
    - name: /usr/local/share/consul/ui
    - watch:
      - file: consul-ui-install

# Install template renderer
consul-template-download:
  file.managed:
    - name: /tmp/consul_template_{{ consul.template_version }}_linux_amd64.zip
    - source: https://github.com/hashicorp/consul-template/releases/download/v{{ consul.template_version }}/consul_template_{{ consul.template_version }}_linux_amd64.zip
    - source_hash: sha1={{ consul.template_hash }}
    - unless: test -f /usr/local/bin/consul-template-{{ consul.template_version }}

consul-template-extract:
  cmd.wait:
    - name: unzip /tmp/consul_template_{{ consul.template_version }}_linux_amd64.zip -d /tmp
    - watch:
      - file: consul-template-download

consul-template-install:
  file.rename:
    - name: /usr/local/bin/consul-template-{{ consul.template_version }}
    - source: /tmp/consul-template
    - require:
      - file: /usr/local/bin
    - watch:
      - cmd: consul-template-extract

consul-template-clean:
  file.absent:
    - name: /tmp/consul_template_{{ consul.template_version }}_linux_amd64.zip
    - watch:
      - file: consul-template-install

consul-template-link:
  file.symlink:
    - target: consul-template-{{ consul.template_version }}
    - name: /usr/local/bin/consul-template
    - watch:
      - file: consul-template-install