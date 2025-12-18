import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 168, 159, 182), // Dark modern color from your data
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      // Profile Avatar with Badge
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.purple],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 41, 44, 46).withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                Icons.verified,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 20),
                      // Name and Role
                      Text(
                        'Md. Rakib Mridha',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.security,
                              size: 16,
                              color: const Color.fromARGB(255, 34, 32, 34),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Super Admin',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Quick Stats
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFD),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              title: 'Users',
                              value: '256',
                              icon: Icons.people_outline,
                              color: Colors.blue,
                            ),
                            _buildStatItem(
                              title: 'Tasks',
                              value: '42',
                              icon: Icons.task_outlined,
                              color: Colors.green,
                            ),
                            _buildStatItem(
                              title: 'Logs',
                              value: '1.2k',
                              icon: Icons.history_outlined,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Contact Information Section
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        title: 'Email Address',
                        subtitle: 'rakib.md@college.edu',
                        color: Colors.blue,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        title: 'Phone Number',
                        subtitle: '+8801611053901',
                        color: Colors.green,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildInfoTile(
                        icon: Icons.location_on_outlined,
                        title: 'Location',
                        subtitle: 'Dhaka, Bangladesh',
                        color: Colors.red,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildInfoTile(
                        icon: Icons.access_time_outlined,
                        title: 'Last Active',
                        subtitle: '2 hours ago',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Admin Privileges Section
                Text(
                  'Admin Privileges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPrivilegeTile(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Full System Access',
                        subtitle: 'Unrestricted access to all modules',
                        active: true,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildPrivilegeTile(
                        icon: Icons.security_outlined,
                        title: 'Security Management',
                        subtitle: 'Manage user roles and permissions',
                        active: true,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildPrivilegeTile(
                        icon: Icons.analytics_outlined,
                        title: 'Analytics Dashboard',
                        subtitle: 'Access to detailed analytics',
                        active: true,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      _buildPrivilegeTile(
                        icon: Icons.backup_outlined,
                        title: 'Database Backup',
                        subtitle: 'Create and restore backups',
                        active: false,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                GridView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  children: [
                    _buildActionButton(
                      icon: Icons.add,
                      label: 'Add User',
                      color: Colors.blue,
                    ),
                    _buildActionButton(
                      icon: Icons.report,
                      label: 'Report',
                      color: Colors.green,
                    ),
                    _buildActionButton(
                      icon: Icons.notifications_active_outlined,
                      label: 'Alerts',
                      color: Colors.orange,
                    ),
                    _buildActionButton(
                      icon: Icons.bar_chart_outlined,
                      label: 'Analytics',
                      color: Colors.purple,
                    ),
                    _buildActionButton(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      color: Colors.teal,
                    ),
                    _buildActionButton(
                      icon: Icons.help_outline,
                      label: 'Help',
                      color: Colors.indigo,
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Logout Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.redAccent, Colors.red],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.logout_outlined),
                    label: Text(
                      'Logout',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                SizedBox(height: 30), // Extra space at bottom
              ],
            ),
          ),
        ),
      ),
      
      // Bottom Navigation with your specified color
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1D1B20), // Your specified color: red: 0.1137, green: 0.1059, blue: 0.1255
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.dashboard_outlined, 'Dashboard', true),
                _buildBottomNavItem(Icons.people_outlined, 'Users', false),
                _buildBottomNavItem(Icons.bar_chart_outlined, 'Analytics', false),
                _buildBottomNavItem(Icons.person_outline, 'Profile', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_outlined,
        color: Colors.grey[400],
      ),
      onTap: () {},
    );
  }

  Widget _buildPrivilegeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool active,
  }) {
    return ListTile(
      leading: Icon(icon, color: active ? Colors.green : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: active ? Colors.black87 : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: active ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: active ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          active ? Icons.check : Icons.close,
          size: 16,
          color: active ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool active) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: active ? Colors.blue.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: active ? Colors.blue : Colors.grey[400],
              size: 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? Colors.blue : Colors.grey[400],
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}