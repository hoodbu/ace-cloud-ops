#config-version=FGTAWS-6.2.3-FW-build1066-200327:opmode=0:vdom=0:user=admin
#conf_file_ver=187393718135403
#buildno=8404
#global_vdom=1
config system global
    set hostname "${name}"
    set timezone 04
    set admintimeout 60
end

config system admin
    edit "admin"
        set accprofile "super_admin"
        set vdom "root"
        set password "${password}"
        set gui-default-dashboard-template "minimal"
        set gui-ignore-release-overview-version "7.0.0"
    next
end

config system accprofile
    edit "ACE"
        set netgrp read-write
        set route-cfg read-write
    next
end

config system api-user
    edit "ACE"
        set api-key ENC SH2OYq5EIdBzJHpLrUn7nSeX2xOgOzD1nVT6I16bNVEm4+qp9L+khRDWzcCSvQ=
        set accprofile "ACE"
        set vdom "root"
    next
end

config system interface
    edit "port1"
        set mode dhcp
        set allowaccess ping https ssh http fgfm
        set type physical
        set alias "WAN"
        set role wan
    next
    edit "port2"
        set mode dhcp
        set allowaccess https http
        set type physical
        set alias "LAN"
        set role lan
    next
end

config firewall policy
    edit 1
        set name "ACE"
        set srcintf "port2"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
    next
end
