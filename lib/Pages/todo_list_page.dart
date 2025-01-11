import 'package:final_project/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _todoController = TextEditingController();
  final _supabase = Supabase.instance.client;
  List<Todo> _todos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final response = await _supabase
          .from('todos')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at');
      setState(() {
        _todos = (response as List).map((json) => Todo.fromJson(json)).toList();
        _loading = false;
      });
    } on PostgrestException catch (e) {
      _showSnackBar('Failed to load todos: ${e.message}');
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _addTodo() async {
    final title = _todoController.text.trim();
    if (title.isEmpty) return;

    try {
      final response = await _supabase.from('todos').insert({
        'title': title,
        'completed': false,
        'user_id': _supabase.auth.currentUser?.id,
      }).select();

      setState(() {
        _todos.add(Todo.fromJson(response.first));
        _todoController.clear();
      });
    } on PostgrestException catch (e) {
      _showSnackBar('Failed to add todo: ${e.message}');
    }
  }

  Future<void> _toggleTodo(Todo todo) async {
    try {
      final response = await _supabase
          .from('todos')
          .update({'completed': !todo.completed})
          .eq('id', todo.id)
          .select();

      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        _todos[index] = Todo.fromJson(response.first);
      });
    } on PostgrestException catch (e) {
      _showSnackBar('Failed to update todo: ${e.message}');
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    setState(() => _todos.removeAt(index));

    try {
      await _supabase.from('todos').delete().eq('id', todo.id);
      _showSnackBar('Todo deleted successfully', isError: false);
    } on PostgrestException catch (e) {
      setState(() => _todos.insert(index, todo));
      _showSnackBar('Failed to delete todo: ${e.message}');
    }
  }

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      _showSnackBar('Failed to sign out: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTodoInput(),
                Expanded(child: _buildTodoList()),
              ],
            ),
    );
  }

  Widget _buildTodoInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _todoController,
              decoration: const InputDecoration(
                hintText: 'Add new task...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addTodo(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _addTodo,
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _todos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return Card(
          child: ListTile(
            leading: Checkbox(
              value: todo.completed,
              onChanged: (_) => _toggleTodo(todo),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTodo(todo),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }
}
