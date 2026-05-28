import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap_app/models/request_model.dart';
import 'package:skillswap_app/services/chat_service.dart';
import 'package:skillswap_app/services/notification_service.dart';
import 'package:skillswap_app/services/request_service.dart';

void main() {
  group('RequestService', () {
    late FakeFirebaseFirestore firestore;
    late RequestService service;
    late ChatService chatService;
    late NotificationService notificationService;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      chatService = ChatService(db: firestore);
      notificationService = NotificationService(firestore: firestore);
      service = RequestService(
        db: firestore,
        chatService: chatService,
        notificationService: notificationService,
      );
    });

    RequestModel buildRequest({
      String id = '',
      String fromUserId = 'requester_1',
      String fromUserName = 'Jamie Smith',
      String toUserId = 'provider_1',
      String listingId = 'listing_1',
      String skillName = 'Flutter',
      String message = 'Can you teach Flutter?',
      String status = 'pending',
      List<String> proposedTimes = const ['Mon 10am', 'Tue 2pm'],
    }) {
      return RequestModel(
        id: id,
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        toUserId: toUserId,
        toUserName: 'Test Recipient',
        listingId: listingId,
        skillName: skillName,
        message: message,
        status: status,
        proposedTimes: proposedTimes,
        createdAt: DateTime(2024, 1, 1, 10, 0),
        updatedAt: DateTime(2024, 1, 1, 10, 0),
      );
    }

    Future<void> seedPendingRequest() async {
      await firestore
          .collection('requests')
          .doc('existing_request')
          .set(buildRequest().copyWith(id: 'existing_request').toMap());
    }

    test('sendRequest() writes document status=pending', () async {
      final requestId = await service.sendRequest(buildRequest());

      final doc = await firestore.collection('requests').doc(requestId).get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['status'], 'pending');
      expect(doc.data()?['fromUserId'], 'requester_1');
    });

    test('sendRequest() duplicate throws exception', () async {
      await seedPendingRequest();

      await expectLater(
        service.sendRequest(buildRequest()),
        throwsA(isA<Exception>()),
      );
    });

    test('sendRequest() creates conversation', () async {
      final requestId = await service.sendRequest(buildRequest());
      expect(requestId, isNotEmpty);

      final conversations = await firestore.collection('conversations').get();
      expect(conversations.docs, hasLength(1));
      expect(conversations.docs.first.data()['participants'], [
        'requester_1',
        'provider_1',
      ]);
    });

    test('sendRequest() creates notification for provider', () async {
      await service.sendRequest(buildRequest());

      final notifications =
          await firestore
              .collection('notifications')
              .where('userId', isEqualTo: 'provider_1')
              .where('type', isEqualTo: 'request')
              .get();

      expect(notifications.docs, hasLength(1));
      expect(
        notifications.docs.first.data()['title'],
        'New lesson request from Jamie Smith',
      );
      expect(
        notifications.docs.first.data()['subtitle'],
        'wants to learn Flutter',
      );
    });

    test('acceptRequest() sets status=accepted', () async {
      await seedPendingRequest();

      await service.acceptRequest(
        'existing_request',
        {'startTime': '10:00', 'endTime': '11:00'},
        'Jamie Smith',
        'Flutter',
        'requester_1',
      );

      final doc =
          await firestore.collection('requests').doc('existing_request').get();
      expect(doc.data()?['status'], 'accepted');
      expect(doc.data()?['confirmedSlot'], {
        'startTime': '10:00',
        'endTime': '11:00',
      });
    });

    test('acceptRequest() creates notification for requester', () async {
      await seedPendingRequest();

      await service.acceptRequest(
        'existing_request',
        {'startTime': '10:00', 'endTime': '11:00'},
        'Jamie Smith',
        'Flutter',
        'requester_1',
      );

      final notifications =
          await firestore
              .collection('notifications')
              .where('userId', isEqualTo: 'requester_1')
              .where('type', isEqualTo: 'accepted')
              .get();

      expect(notifications.docs, hasLength(1));
      expect(
        notifications.docs.first.data()['title'],
        'Your request was accepted!',
      );
    });

    test('declineRequest() sets status=declined', () async {
      await seedPendingRequest();

      await service.declineRequest(
        'existing_request',
        'requester_1',
        'Flutter',
      );

      final doc =
          await firestore.collection('requests').doc('existing_request').get();
      expect(doc.data()?['status'], 'declined');
    });

    test('declineRequest() creates notification', () async {
      await seedPendingRequest();

      await service.declineRequest(
        'existing_request',
        'requester_1',
        'Flutter',
      );

      final notifications =
          await firestore
              .collection('notifications')
              .where('userId', isEqualTo: 'requester_1')
              .where('type', isEqualTo: 'declined')
              .get();

      expect(notifications.docs, hasLength(1));
      expect(
        notifications.docs.first.data()['title'],
        'Your request was declined',
      );
    });

    test('counterRequest() sets status=countered', () async {
      await seedPendingRequest();

      await service.counterRequest(
        'existing_request',
        [
          {'startTime': '12:00', 'endTime': '13:00'},
        ],
        'Try this slot',
        'requester_1',
        'Flutter',
      );

      final doc =
          await firestore.collection('requests').doc('existing_request').get();
      expect(doc.data()?['status'], 'countered');
    });

    test('counterRequest() replaces proposedTimes', () async {
      await seedPendingRequest();

      await service.counterRequest(
        'existing_request',
        [
          {'startTime': '12:00', 'endTime': '13:00'},
        ],
        'Try this slot',
        'requester_1',
        'Flutter',
      );

      final doc =
          await firestore.collection('requests').doc('existing_request').get();
      expect(doc.data()?['proposedTimes'], [
        {'startTime': '12:00', 'endTime': '13:00'},
      ]);
      expect(doc.data()?['counterNote'], 'Try this slot');
    });

    test('getIncomingRequests() stream correct', () async {
      await firestore
          .collection('requests')
          .doc('request_1')
          .set(buildRequest(id: 'request_1', toUserId: 'provider_1').toMap());
      await firestore
          .collection('requests')
          .doc('request_2')
          .set(
            buildRequest(
              id: 'request_2',
              fromUserId: 'requester_2',
              fromUserName: 'Alex Brown',
              toUserId: 'provider_1',
            ).toMap(),
          );
      await firestore
          .collection('requests')
          .doc('request_3')
          .set(
            buildRequest(
              id: 'request_3',
              fromUserId: 'requester_3',
              fromUserName: 'Taylor Lee',
              toUserId: 'other_provider',
            ).toMap(),
          );

      await expectLater(
        service.getIncomingRequests('provider_1'),
        emits(
          predicate((List<RequestModel> requests) {
            return requests.length == 2 &&
                requests.every((request) => request.toUserId == 'provider_1');
          }),
        ),
      );
    });
  });
}
