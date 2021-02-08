### Permission Group Definition
resource "aviatrix_rbac_group" "rbac_group_100" {
    group_name = "local-students"
    local_login = false
}

### Permission Group to Access Account Attachment 
resource "aviatrix_rbac_group_access_account_attachment" "rbac_group_access_account_attachment_1" {
    group_name = "local-students"
    access_account_name = "all"
}


### Permission Group to User Attachment
resource "aviatrix_rbac_group_user_attachment" "rbac_group_user_attachment_1" {
    group_name = "local-students"
    user_name = "pod1"
}


### Permission User Credentials
resource "aviatrix_account_user" "account_user_1" {
    username = "pod1"
    email = "uhoodbhoy@aviatrix.com"
    password = var.ace_password
}

### Permission Group to Permission Set Attachment
resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_1" {
    group_name = "local-students"
    permission_name = "all_dashboard_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_2" {
    group_name = "local-students"
    permission_name = "all_accounts_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_3" {
    group_name = "local-students"
    permission_name = "all_gateway_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_4" {
    group_name = "local-students"
    permission_name = "all_tgw_orchestrator_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_5" {
    group_name = "local-students"
    permission_name = "all_transit_network_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_6" {
    group_name = "local-students"
    permission_name = "all_firewall_network_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_7" {
    group_name = "local-students"
    permission_name = "all_cloud_wan_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_8" {
    group_name = "local-students"
    permission_name = "all_peering_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_9" {
    group_name = "local-students"
    permission_name = "all_site2cloud_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_10" {
    group_name = "local-students"
    permission_name = "all_openvpn_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_11" {
    group_name = "local-students"
    permission_name = "all_security_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_12" {
    group_name = "local-students"
    permission_name = "all_useful_tools_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_13" {
    group_name = "local-students"
    permission_name = "all_troubleshoot_write"
}

resource "aviatrix_rbac_group_permission_attachment" "rbac_group_permission_attachment_14" {
    group_name = "local-students"
    permission_name = "all_write"
}

