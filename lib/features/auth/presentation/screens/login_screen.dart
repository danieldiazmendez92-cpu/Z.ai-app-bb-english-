import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/se_button.dart';
import '../../../../core/widgets/se_text_field.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../widgets/social_login_buttons.dart';

/// Pantalla de inicio de sesión.
///
/// Permite:
/// - Login con email y password
/// - Login con Google
/// - Login con Apple
/// - Recuperar contraseña (link a [PasswordResetScreen])
/// - Ir a [SignupScreen] si no hay cuenta
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Quitar foco del teclado
    FocusScope.of(context).unfocus();

    await ref.read(authControllerProvider.notifier).loginWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar errores del controller
    ref.listen<AsyncValue>(authControllerProvider, (previous, next) {
      if (next.hasError && next.error is Failure) {
        _showError((next.error as Failure).message);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo y bienvenida
                const SizedBox(height: 24),
                Icon(
                  Icons.auto_stories,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'StoryEnglish Kids',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¡Bienvenido de vuelta!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),

                const SizedBox(height: 40),

                // Form
                SETextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: Validators.validateEmail,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                SETextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: Validators.validatePassword,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _submit(),
                ),

                // Olvidé contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.push(Routes.passwordReset),
                    child: const Text('Olvidé mi contraseña'),
                  ),
                ),

                const SizedBox(height: 16),

                // Botón principal
                SEButton(
                  onPressed: isLoading ? null : _submit,
                  label: 'Iniciar sesión',
                  isLoading: isLoading,
                  size: SEButtonSize.large,
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'o continuá con',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Social login
                SocialLoginButtons(
                  onGoogleTap: isLoading
                      ? null
                      : () => ref
                          .read(authControllerProvider.notifier)
                          .loginWithGoogle(),
                  onAppleTap: isLoading
                      ? null
                      : () => ref
                          .read(authControllerProvider.notifier)
                          .loginWithApple(),
                ),

                const SizedBox(height: 32),

                // Link a signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tenés cuenta?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.push(Routes.signup),
                      child: const Text('Registrate acá'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
