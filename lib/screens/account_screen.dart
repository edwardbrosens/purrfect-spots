import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';

/// Account screen — sign in / sign up with email+password or Google.
/// Shows account details (incl. username#tag) when signed in.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _userCtl = TextEditingController();
  bool _isSignUp = true;
  String? _error;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    _userCtl.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    String? err;
    if (_isSignUp) {
      err = await auth.signUpWithEmail(
        email: _emailCtl.text.trim(),
        password: _passCtl.text,
        username: _userCtl.text.trim(),
      );
    } else {
      err = await auth.signInWithEmail(
        email: _emailCtl.text.trim(),
        password: _passCtl.text,
      );
    }
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
    } else {
      // Reload progress under the new uid
      await context.read<ProgressProvider>().initialize(auth.uid);
      if (!mounted) return;
      context.go('/settings');
    }
  }

  Future<void> _confirmSignOut(AuthProvider auth) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign back in any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await auth.signOut();
      if (!mounted) return;
      await context.read<ProgressProvider>().initialize(auth.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loggedIn = !auth.isAnonymous;

    return Scaffold(
      backgroundColor: CatCafeTheme.background,
      appBar: AppBar(
        title: const Text('Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (loggedIn) ..._buildLoggedIn(auth) else ..._buildAuthForm(auth),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoggedIn(AuthProvider auth) {
    final p = auth.profile;
    return [
      Card(
        color: CatCafeTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: CatCafeTheme.primary,
                    backgroundImage: p?.avatarUrl != null
                        ? NetworkImage(p!.avatarUrl!)
                        : null,
                    child: p?.avatarUrl == null
                        ? const Icon(Icons.person,
                            color: CatCafeTheme.darkText, size: 32)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p?.displayName ?? auth.displayName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (p?.usernameTag != null)
                          Text(
                            '#${p!.usernameTag.toString().padLeft(4, '0')}',
                            style: TextStyle(
                              color: CatCafeTheme.darkText.withValues(alpha: 0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _kv('Email', auth.user?.email ?? '—'),
              _kv('Provider', p?.authProvider ?? '—'),
              _kv('Stars', '${p?.totalStars ?? 0}'),
              _kv('Levels cleared', '${p?.levelsCompleted ?? 0}'),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        onPressed: () => _confirmSignOut(auth),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sign out'),
      ),
    ];
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(k,
                  style: TextStyle(
                      color: CatCafeTheme.darkText.withValues(alpha: 0.6))),
            ),
            Expanded(
                child: Text(v,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );

  List<Widget> _buildAuthForm(AuthProvider auth) {
    return [
      ToggleButtons(
        isSelected: [_isSignUp, !_isSignUp],
        borderRadius: BorderRadius.circular(8),
        onPressed: (i) => setState(() => _isSignUp = i == 0),
        children: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Text('Sign up')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Text('Sign in')),
        ],
      ),
      const SizedBox(height: 16),
      Form(
        key: _formKey,
        child: Column(
          children: [
            if (_isSignUp)
              TextFormField(
                controller: _userCtl,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (!_isSignUp) return null;
                  if (v == null || v.trim().length < 2) {
                    return 'At least 2 characters';
                  }
                  if (v.trim().length > 20) return 'Max 20 characters';
                  return null;
                },
              ),
            if (_isSignUp) const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || !v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passCtl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
          ],
        ),
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: auth.isLoading ? null : () => _submit(auth),
          child: Text(_isSignUp ? 'Create account' : 'Sign in'),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('or',
                style: TextStyle(color: CatCafeTheme.darkText.withValues(alpha: 0.6))),
          ),
          const Expanded(child: Divider()),
        ],
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: auth.isLoading
              ? null
              : () async {
                  // For Google sign-in we don't ask for a username up-front;
                  // if it's a new account we'll auto-derive one from the email.
                  final err = await auth.signInWithGoogle(
                    username: _userCtl.text.trim().isEmpty
                        ? null
                        : _userCtl.text.trim(),
                  );
                  if (!mounted) return;
                  if (err != null) {
                    setState(() => _error = err);
                    return;
                  }
                  if (!auth.isAnonymous) {
                    await context.read<ProgressProvider>().initialize(auth.uid);
                    if (!mounted) return;
                    context.go('/settings');
                  }
                },
          icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
          label: const Text('Continue with Google'),
        ),
      ),
    ];
  }
}
