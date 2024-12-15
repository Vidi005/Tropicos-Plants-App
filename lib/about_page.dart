import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  openUrl(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('About'),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          shadowColor: Theme.of(context).shadowColor,
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                'Tropicos Plants App',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  fontStyle: Theme.of(context).textTheme.titleLarge?.fontStyle,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This application is made for completing submission of Create Flutter Application for Beginner course on Dicoding Academy.',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  fontStyle: Theme.of(context).textTheme.bodyMedium?.fontStyle,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Contents Source:',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                  fontStyle: Theme.of(context).textTheme.titleMedium?.fontStyle,
                  fontWeight:
                      Theme.of(context).textTheme.titleMedium?.fontWeight,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.bodyMedium?.fontSize,
                      fontStyle:
                          Theme.of(context).textTheme.bodyMedium?.fontStyle,
                      fontWeight:
                          Theme.of(context).textTheme.bodyMedium?.fontWeight,
                    ),
                    children: [
                      TextSpan(
                        text: 'https://tropicos.org/',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => openUrl('https://tropicos.org/'),
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' Missouri Botanical Garden.')
                    ]),
              ),
              const SizedBox(height: 16),
              Text(
                'API Service Source:',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                  fontStyle: Theme.of(context).textTheme.titleMedium?.fontStyle,
                  fontWeight:
                      Theme.of(context).textTheme.titleMedium?.fontWeight,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => openUrl('https://services.tropicos.org/'),
                child: Text(
                  'https://services.tropicos.org/',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                    fontStyle:
                        Theme.of(context).textTheme.bodyMedium?.fontStyle,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
