import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

// Placeholder for future API integration
class ApiService {
  Future<void> fetchData() async {
    // Placeholder for fetching data from an API
    await Future.delayed(const Duration(seconds: 2));
    print('API data fetched successfully');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  File? _image; // Lifted state
  String _name = 'John Doe'; // Lifted state
  String _email = 'john.doe@example.com'; // Lifted state
  String _bio = 'AI enthusiast and software developer passionate about innovation.'; // Lifted state
  Color _primaryColor = Colors.teal; // Default primary color
  final List<Project> _projects = []; // List of projects
  final List<Goal> _customGoals = []; // List of custom goals

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.teal.value);
    });
  }

  void _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
      prefs.setBool('isDarkMode', value);
    });
  }

  void _updatePrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _primaryColor = color;
      prefs.setInt('primaryColor', color.value);
    });
  }

  // Method to update the image
  void updateImage(File? newImage) {
    setState(() {
      _image = newImage;
    });
  }

  // Method to update the profile details
  void updateProfile(String newName, String newEmail, File? newImage, String newBio) {
    setState(() {
      _name = newName;
      _email = newEmail;
      _image = newImage;
      _bio = newBio;
    });
  }

  // Method to add a new project
  void addProject(Project project) {
    setState(() {
      _projects.add(project);
    });
  }

  // Method to add a new goal
  void addGoal(Goal goal) {
    setState(() {
      _customGoals.add(goal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Incubationist.AI',
      theme: _isDarkMode
          ? _darkTheme
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor, brightness: Brightness.light),
              scaffoldBackgroundColor: Colors.white,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
                bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
                headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red), // Red tone
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: _primaryColor, // Use primary color
                elevation: 4,
                titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(
          toggleDarkMode: _toggleDarkMode, isDarkMode: _isDarkMode, updateImage: updateImage, image: _image, name: _name, email: _email, bio: _bio, updateProfile: updateProfile, primaryColor: _primaryColor, customGoals: _customGoals, updatePrimaryColor: _updatePrimaryColor, projects: _projects,
        ),
        '/profile': (context) => ProfilePage(
          name: _name, email: _email, profileImage: _image, bio: _bio, updateProfile: updateProfile,
        ),
        '/settings': (context) => SettingsPage(
          notificationsEnabled: false, // Default value
          onNotificationToggle: (value) {},
          isDarkMode: _isDarkMode,
          onDarkModeToggle: _toggleDarkMode,
        ),
        '/goals': (context) => GoalsPage(
          addGoal: addGoal,
        ),
        '/projects': (context) => ProjectsPage(
          projects: _projects, addProject: addProject,),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(bool) toggleDarkMode; // Dark mode toggle function
  final bool isDarkMode;
  final Function(File?) updateImage;
  final File? image;
  final String name;
  final String email;
  final String bio;
  final Function(String, String, File?, String) updateProfile;
  final Color primaryColor;
  final List<Goal> customGoals;
  final Function(Color) updatePrimaryColor;
  final List<Project> projects;

  const MyHomePage({
    Key? key,
    required this.toggleDarkMode,
    required this.isDarkMode,
    required this.updateImage,
    required this.image,
    required this.name,
    required this.email,
    required this.bio,
    required this.updateProfile,
    required this.primaryColor,
    required this.customGoals,
    required this.updatePrimaryColor,
    required this.projects,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Function to pick image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      widget.updateImage(File(image.path)); // Use the passed function
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incubationist.AI', style: TextStyle(color: Colors.white)), // White text
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Navigation drawer
          children: [ // Navigation drawer
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal), // Header background color
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Goals'),
              onTap: () => Navigator.pushNamed(context, '/goals'),
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Projects'),
              onTap: () => Navigator.pushNamed(context, '/projects'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage, // Call _pickImage on tap
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.image != null ? FileImage(widget.image!) : const AssetImage('assets/profile.jpeg') as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('🎤 AI Task Instructions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildAiTaskInput(),
              const SizedBox(height: 20),
              Text(
                widget.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Dashboard
              Dashboard(primaryColor: widget.primaryColor, customGoals: widget.customGoals, updatePrimaryColor: widget.updatePrimaryColor, projects: widget.projects),

              const SizedBox(height: 30),
              const Text('📅 Task Scheduler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiTaskInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12), // AI task input
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Enter instructions for the AI',
            border: InputBorder.none,
            icon: Icon(Icons.mic, color: widget.primaryColor),
          ),
          maxLines: 3,
          onSubmitted: (value) {
            print('AI Instructions: $value');
          },
        ),
      ),
    );
  }
}

// Dashboard Widget
class Dashboard extends StatefulWidget {
  final Color primaryColor;
  final List<Goal> customGoals;
  final Function(Color) updatePrimaryColor;
  final List<Project> projects;

  const Dashboard({Key? key, required this.primaryColor, required this.customGoals, required this.updatePrimaryColor, required this.projects}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Goal> weeklyGoals = [
    Goal(text: 'Complete 5 Active Projects', isCompleted: false),
    Goal(text: 'Spend 40 Hours on Tasks', isCompleted: false),
    Goal(text: 'Maintain Productivity Streak', isCompleted: false),
  ];

  List<Task> upcomingTasks = [];

  Color _selectedColor = Colors.teal;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.primaryColor;
  }

/*  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    upcomingTasks = _getUpcomingTasks(widget.projects);
  }*/

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📊 Dashboard Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('Active Projects', widget.projects.length.toString(), () {
              Navigator.pushNamed(context, '/projects');
            }),
            _buildStatCard('AI Models Used', '3', () {}),
            _buildStatCard('Tasks Completed', '12', () {}),
          ],
        ),
        const SizedBox(height: 30),

        // Task Completion Statistics
        const Text('✅ Task Completion Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard('Tasks Completed', '25', () {}),
            _buildStatCard('Time Spent (Hours)', '40', () {}),
            _buildStatCard('Productivity Streak', '7 days', () {}),
          ],
        ),

        const SizedBox(height: 30),

        // Goal Setting and Tracking
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🎯 Weekly Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/goals');
              },
              child: const Text('Edit Goals'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            ...weeklyGoals.map((goal) => _buildGoalCheckbox(goal)),
            ...widget.customGoals.map((goal) => _buildGoalCheckbox(goal)),
          ],
        ),

        const SizedBox(height: 30),

        // Progress Tracker
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('📈 Productivity Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<Color>(
              value: _selectedColor,
              items: [
                DropdownMenuItem(
                  value: Colors.teal,
                  child: Text('Teal', style: TextStyle(color: Colors.teal)),
                ),
                DropdownMenuItem(
                  value: Colors.blue,
                  child: Text('Blue', style: TextStyle(color: Colors.blue)),
                ),
                DropdownMenuItem(
                  value: Colors.green,
                  child: Text('Green', style: TextStyle(color: Colors.green)),
                ),
                DropdownMenuItem(
                  value: Colors.orange,
                  child: Text('Orange', style: TextStyle(color: Colors.orange)),
                ),
                DropdownMenuItem(
                  value: Colors.purple,
                  child: Text('Purple', style: TextStyle(color: Colors.purple)),
                ),
              ],
              onChanged: (Color? newValue) {
                setState(() {
                  _selectedColor = newValue!;
                  widget.updatePrimaryColor(newValue);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 3),
                    const FlSpot(1, 2.5),
                    const FlSpot(2, 4),
                    const FlSpot(3, 3.5),
                    const FlSpot(4, 5),
                    const FlSpot(5, 4.5),
                    const FlSpot(6, 6),
                  ],
                  isCurved: true,
                  color: _selectedColor,
                  barWidth: 5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                ),
              ],
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCheckbox(Goal goal) {
    return CheckboxListTile(
      title: Text(
        goal.text,
        style: TextStyle(
          decoration: goal.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      value: goal.isCompleted,
      onChanged: (bool? newValue) {
        setState(() {
          goal.isCompleted = newValue ?? false;
        });
      },
    );
  }
}

class Task {
  String name;
  DateTime dueDate;

  Task({required this.name, required this.dueDate});
}

class Goal {
  String text;
  bool isCompleted;

  Goal({required this.text, required this.isCompleted});
}

// Projects Page
class ProjectsPage extends StatefulWidget {
  final List<Project> projects;
  final Function(Project) addProject;

  const ProjectsPage({Key? key, required this.projects, required this.addProject}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects', style: TextStyle(color: Colors.white))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddNewProjectPage(addProject: widget.addProject)),
                );
              },
              child: const Text('Add a new project here'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.projects.length,
              itemBuilder: (context, index) {
                final project = widget.projects[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProjectDetailPage(project: project)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(project.description),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddNewProjectPage extends StatefulWidget {
  final Function(Project) addProject;

  const AddNewProjectPage({Key? key, required this.addProject}) : super(key: key);

  @override
  State<AddNewProjectPage> createState() => _AddNewProjectPageState();
}

class _AddNewProjectPageState extends State<AddNewProjectPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Project', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Project Title:'),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Enter project title'),
            ),
            const SizedBox(height: 16),
            const Text('Project Description:'),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Enter project description'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final description = _descriptionController.text;
                if (title.isNotEmpty && description.isNotEmpty) {
                  final newProject = Project(name: title, description: description, tasks: [], calendarEvents: [], participants: []);
                  widget.addProject(newProject);
                  Navigator.pop(context); // Go back to the projects page
                }
              },
              child: const Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectDetailPage extends StatefulWidget {
  final Project project;

  const ProjectDetailPage({Key? key, required this.project}) : super(key: key);

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.name, style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Calendar'),
              Tab(text: 'Participants'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProjectTasksTab(project: widget.project),
            ProjectCalendarTab(project: widget.project),
            ProjectParticipantsTab(project: widget.project),
          ],
        ),
      ),
    );
  }
}

class ProjectTasksTab extends StatelessWidget {
  final Project project;

  const ProjectTasksTab({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Tasks for ${project.name} will be displayed here.'),
    );
  }
}

class ProjectCalendarTab extends StatelessWidget {
  final Project project;

  const ProjectCalendarTab({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Calendar for ${project.name} will be displayed here.'),
    );
  }
}

class ProjectParticipantsTab extends StatelessWidget {
  final Project project;

  const ProjectParticipantsTab({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Participants for ${project.name} will be displayed here.'),
    );
  }
}

// Project Model
class Project {
  final String name;
  final String description;
  List<String> tasks;
  List<DateTime> calendarEvents;
  List<String> participants;

  Project({required this.name, required this.description, required this.tasks, required this.calendarEvents, required this.participants});
}

// Enhanced Profile Page with Editable Fields
class ProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final File? profileImage;
  final String bio;
  final Function(String, String, File?, String) updateProfile;

  const ProfilePage({
    Key? key,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.bio,
    required this.updateProfile,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _name;
  late String _email;
  File? _profileImage;
  late String _bio;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _email = widget.email;
    _profileImage = widget.profileImage;
    _bio = widget.bio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/profile.jpeg') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text('Email: $_email', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            const Text('Bio:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(_bio),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      name: _name,
                      email: _email,
                      profileImage: _profileImage,
                      bio: _bio,
                    ),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  // Handle the updated data
                  setState(() {
                    _name = result['name'] ?? _name;
                    _email = result['email'] ?? _email;
                    _profileImage = result['profileImage'] ?? _profileImage;
                    _bio = result['bio'] ?? _bio;
                  });

                  // Update the profile in the parent widget
                  widget.updateProfile(_name, _email, _profileImage, _bio);
                }
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final File? profileImage;
  final String bio;

  const EditProfilePage({Key? key, required this.name, required this.email, required this.profileImage, required this.bio}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _bioController = TextEditingController(text: widget.bio);
    _newProfileImage = widget.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        _newProfileImage = File(image.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _newProfileImage != null
                      ? FileImage(_newProfileImage!)
                      : const AssetImage('assets/profile.jpeg') as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'profileImage': _newProfileImage,
                  'bio': _bioController.text,
                });
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeCustomizationPage extends StatefulWidget {
  final Color primaryColor;
  final ValueChanged<Color> onColorChanged;

  const ThemeCustomizationPage({Key? key, required this.primaryColor, required this.onColorChanged}) : super(key: key);

  @override
  State<ThemeCustomizationPage> createState() => _ThemeCustomizationPageState();
}

class _ThemeCustomizationPageState extends State<ThemeCustomizationPage> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Customization', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Primary Color:'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: [
                _buildColorButton(Colors.teal),
                _buildColorButton(Colors.blue),
                _buildColorButton(Colors.green),
                _buildColorButton(Colors.orange),
                _buildColorButton(Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
          widget.onColorChanged(color);
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: _selectedColor == color ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }
}

class GoalsPage extends StatefulWidget {
  final Function(Goal) addGoal;

  const GoalsPage({Key? key, required this.addGoal}) : super(key: key);

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add a new goal:'),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(hintText: 'Enter your goal'),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  widget.addGoal(Goal(text: value, isCompleted: false));
                  _textController.clear();
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  widget.addGoal(Goal(text: _textController.text, isCompleted: false));
                  _textController.clear();
                }
              },
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Settings Page with Dark Mode Toggle and Notifications
class SettingsPage extends StatefulWidget {
  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationToggle;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeToggle;

  const SettingsPage({
    Key? key,
    required this.notificationsEnabled,
    required this.onNotificationToggle,
    required this.isDarkMode,
    required this.onDarkModeToggle,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _notificationsEnabled;
  late bool _darkModeEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = widget.notificationsEnabled;
    _darkModeEnabled = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                  widget.onNotificationToggle(value);
                });
              },
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkModeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _darkModeEnabled = value;
                  widget.onDarkModeToggle(value);
                });
              },
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Privacy Policy'),
              onTap: () {
                // Handle privacy policy tap
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'AI Task Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter instructions for the AI',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSubmitted: (value) {
                // Handle the submitted instructions
                print('AI Instructions: $value');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Dark theme
ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1E1E1E),
  primaryColor: const Color(0xFFB71C1C), // Dark red
  cardColor: const Color(0xFF2C2C2C),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 14), // Corrected property name
    headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2C2C2C),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // Corrected property name
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF2C2C2C),
    selectedItemColor: Color(0xFFB71C1C),
    unselectedItemColor: Colors.white70,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFB71C1C),
  ),
);

// Project card style
Widget buildProjectCard(String projectName, String status) {
  return Card(
    color: const Color(0xFF2C2C2C),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            projectName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Status: $status",
                style: const TextStyle(color: Colors.white70),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == "In Progress"
                      ? Colors.orange
                      : status == "Completed"
                          ? Colors.green
                          : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}

// Updated Task Card for Calendar View
