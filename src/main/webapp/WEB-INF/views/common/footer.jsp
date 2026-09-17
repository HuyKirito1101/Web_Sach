<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <!-- SockJS & Stomp JS cho WebSocket -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

    <script>
        // Kết nối WebSocket Real-time
        try {
            var socket = new SockJS('/ws');
            var stompClient = Stomp.over(socket);
            stompClient.debug = null; // Tắt log rác
            stompClient.connect({}, function (frame) {
                console.log('WebSocket Connected!');
                
                stompClient.subscribe('/topic/orders', function (msg) {
                    showToastNotification(msg.body);
                });
                
                stompClient.subscribe('/topic/transfers', function (msg) {
                    showToastNotification(msg.body);
                });
            });
        } catch (e) {
            console.log('WebSocket connect error:', e);
        }

        function showToastNotification(text) {
            var badge = document.getElementById('wsBadge');
            if(badge) badge.style.display = 'block';

            alert("🔔 Thông Báo Mới: " + text);
        }
    </script>
</body>
</html>
