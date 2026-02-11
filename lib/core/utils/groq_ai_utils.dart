import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pocketnest/config/environment_config.dart';

class GroqAIUtils {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.1-8b-instant';

  // Generate daily tip based on user data
  static Future<String> generateDailyTip({
    required String userName,
    required Map<String, dynamic>? onboardingData,
    bool skippedOnboarding = false,
  }) async {
    try {
      String systemPrompt;
      String userPrompt;

      if (skippedOnboarding) {
        // Generic friendly tip for users who skipped onboarding
        systemPrompt =
            'You are a warm, supportive financial advisor for busy mums. '
            'Create encouraging, simple, actionable money tips.';
        userPrompt =
            'Create a warm daily money tip for $userName. She is learning about '
            'money confidence. Be friendly, encouraging, and actionable. Max 2 sentences. '
            'Add 1 relevant emoji.';
      } else {
        // Personalized tip based on onboarding responses
        final concerns = _extractConcerns(onboardingData);
        systemPrompt =
            'You are a warm, supportive financial advisor for busy mums. '
            'Create encouraging, personalized money tips based on their specific situation.';
        userPrompt =
            'Create a warm daily tip for $userName based on her situation: $concerns. '
            'Be specific to her concerns. Max 2 sentences. Add 1 relevant emoji.';
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvironmentConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ??
            'You\'re doing amazing, $userName! 💚';
      } else {
        return 'Keep going! Every small step counts 💚';
      }
    } catch (e) {
      return 'You\'re doing amazing, $userName! 💚';
    }
  }

  // Generate card recommendation title
  static Future<String> generateCardTitle({
    required Map<String, dynamic>? onboardingData,
    bool skippedOnboarding = false,
  }) async {
    try {
      String userPrompt;

      if (skippedOnboarding) {
        // Generic title for users who skipped
        userPrompt =
            'Create a warm, encouraging title for a money guidance card for busy mums. '
            'Focus on gentle budgeting and money confidence. Max 5 words. No quotes.';
      } else {
        // Personalized title based on top concern
        final topConcern = _getTopConcern(onboardingData);
        userPrompt =
            'Create a warm, encouraging title for a money guidance card about this: $topConcern. '
            'Make it supportive, not scary. Max 5 words. No quotes.';
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvironmentConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 50,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ??
            'Let\'s talk about money';
      } else {
        return 'Let\'s talk about money';
      }
    } catch (e) {
      return 'Let\'s talk about money';
    }
  }

  // Generate card description based on user data
  static Future<String> generateCardDescription({
    required Map<String, dynamic>? onboardingData,
    bool skippedOnboarding = false,
  }) async {
    try {
      String userPrompt;

      if (skippedOnboarding) {
        // Generic description for skip users - most common concern
        userPrompt =
            'Create a gentle, friendly description for helping busy mums manage groceries '
            'and household budgets. Focus on being supportive and practical. Max 2 sentences.';
      } else {
        // Personalized description
        final topConcern = _getTopConcern(onboardingData);
        userPrompt =
            'Create a warm, practical description for helping with this concern: $topConcern. '
            'Max 2 sentences. Be encouraging and action-oriented.';
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvironmentConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 100,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ??
            'Let us make one gentle plan together.';
      } else {
        return 'Let us make one gentle plan together.';
      }
    } catch (e) {
      return 'Let us make one gentle plan together.';
    }
  }

  // Extract concerns from onboarding data
  static String _extractConcerns(Map<String, dynamic>? onboarding) {
    if (onboarding == null) return 'general money confidence';

    final concerns = <String>[];

    // money_stretch concern
    if (onboarding['money_stretch'] != null &&
        onboarding['money_stretch']['value'] == 'stretch') {
      concerns.add('managing tight budget');
    }

    // time_available concern
    if (onboarding['time_available'] != null) {
      final time = onboarding['time_available']['value'];
      if (time == 'limited') {
        concerns.add('short on time for money tasks');
      }
    }

    // shopping_style
    if (onboarding['shopping_style'] != null) {
      final style = onboarding['shopping_style']['value'];
      if (style == 'impulse') {
        concerns.add('wants to reduce impulse spending');
      }
    }

    // who_for (who is she saving for)
    if (onboarding['who_for'] != null &&
        onboarding['who_for']['value'] != null) {
      final forWho = onboarding['who_for']['value'];
      concerns.add('saving for $forWho');
    }

    // money_feelings
    if (onboarding['money_feelings'] != null) {
      final feelings = onboarding['money_feelings']['value'];
      if (feelings == 'anxious') {
        concerns.add('feels anxious about money');
      }
    }

    return concerns.isEmpty ? 'general money confidence' : concerns.join(', ');
  }

  // Get the top/primary concern
  static String _getTopConcern(Map<String, dynamic>? onboarding) {
    if (onboarding == null) {
      return 'managing household budget and groceries';
    }

    // Priority: money_stretch > who_for > time_available
    if (onboarding['money_stretch'] != null &&
        onboarding['money_stretch']['value'] == 'stretch') {
      return 'managing a tight budget with groceries feeling stretched';
    }

    if (onboarding['who_for'] != null) {
      return 'saving for ${onboarding['who_for']['value']} while managing daily expenses';
    }

    if (onboarding['time_available'] != null &&
        onboarding['time_available']['value'] == 'limited') {
      return 'managing money with limited time availability';
    }

    return 'building money confidence step by step';
  }

  // Generate weekly saving strategy for Save page
  static Future<String> generateWeeklySavingStrategy({
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final systemPrompt =
          'You are a thoughtful financial advisor for busy mums. '
          'Suggest one clever, actionable weekly saving strategy that feels smart, not restrictive. '
          'Focus on lifestyle-aligned savings, not coupon clipping. Be warm and supportive.';

      final userPrompt =
          'Suggest ONE specific, actionable money-saving strategy this user could do this week. '
          'Make it practical and aligned with their lifestyle (busy mum with limited time). '
          'Example: "Batch cooking once this week could reduce waste and save around \$18." '
          'Be specific with estimated savings. Max 1 sentence. No intro/outro.';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${EnvironmentConfig.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['choices']?[0]?['message']?['content'] as String?)
                ?.trim() ??
            'Batch cooking once this week could reduce waste and save around \$18.';
      }

      return 'Batch cooking once this week could reduce waste and save around \$18.';
    } catch (e) {
      return 'Batch cooking once this week could reduce waste and save around \$18.';
    }
  }
}
