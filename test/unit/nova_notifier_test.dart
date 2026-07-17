import 'package:flutter_test/flutter_test.dart';
import 'package:mental_mantra/features/nova/providers/nova_provider.dart';
import 'package:mental_mantra/features/nova/data/models/nova_conversation_history.dart';
import 'package:mental_mantra/features/nova/data/repositories/nova_repository.dart';
import 'package:mental_mantra/features/nova/data/services/nova_service.dart';

class FakeNovaRepository extends NovaRepository {
  List<NovaMessage> savedMessages = [];

  @override
  Future<List<NovaMessage>> loadHistory() async {
    return savedMessages;
  }

  @override
  Future<void> saveHistory(List<NovaMessage> messages) async {
    savedMessages = messages;
  }

  @override
  Future<void> clearHistory() async {
    savedMessages.clear();
  }

  @override
  Future<Map<String, dynamic>?> loadWellnessProfile() async {
    return {'theme': 'warm'};
  }
}

class FakeNovaService extends NovaService {}

void main() {
  test('NovaNotifier starts with empty state', () {
    final repo = FakeNovaRepository();
    final service = FakeNovaService();
    final notifier = NovaNotifier(repository: repo, service: service);

    expect(notifier.state.messages, isEmpty);
    expect(notifier.state.isLoading, isFalse);
    expect(notifier.state.isTyping, isFalse);
    expect(notifier.state.error, isNull);
  });

  test('NovaNotifier loads history correctly', () async {
    final repo = FakeNovaRepository();
    final service = FakeNovaService();
    final msg = NovaMessage(text: 'Hello from past', isUser: true);
    repo.savedMessages = [msg];

    final notifier = NovaNotifier(repository: repo, service: service);
    await notifier.loadHistory();

    expect(notifier.state.messages, hasLength(1));
    expect(notifier.state.messages.first.text, 'Hello from past');
    expect(notifier.state.profile, isNotNull);
  });

  test('NovaNotifier clears chat correctly', () async {
    final repo = FakeNovaRepository();
    final service = FakeNovaService();
    final msg = NovaMessage(text: 'Temporary', isUser: true);
    repo.savedMessages = [msg];

    final notifier = NovaNotifier(repository: repo, service: service);
    await notifier.loadHistory();
    expect(notifier.state.messages, isNotEmpty);

    await notifier.clearChat();
    expect(notifier.state.messages, isEmpty);
    expect(repo.savedMessages, isEmpty);
  });
}
