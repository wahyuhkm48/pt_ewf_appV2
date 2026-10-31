import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_colors.dart';

class TradingViewChart extends StatefulWidget {
  final String symbol;   // contoh: 'OANDA:XAUUSD'
  final String interval; // '15', '60', 'D'
  final double height;

  const TradingViewChart({
    super.key,
    required this.symbol,
    this.interval = 'D',
    this.height = 400,
  });

  @override
  State<TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<TradingViewChart> {
  late final WebViewController _controller;
  late bool _dark;

  @override
  void initState() {
    super.initState();
    _dark = AppColors.isDark;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false)
      ..loadHtmlString(
        _buildHtml(widget.symbol, widget.interval),
        baseUrl: 'https://www.tradingview.com',
    );
  }

  @override
  void didUpdateWidget(covariant TradingViewChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final modeBerubah = _dark != AppColors.isDark;
    if (oldWidget.symbol != widget.symbol ||
        oldWidget.interval != widget.interval ||
        modeBerubah) {
      _dark = AppColors.isDark;
      _controller.loadHtmlString(
        _buildHtml(widget.symbol, widget.interval),
        baseUrl: 'https://www.tradingview.com',
      );
    }
  }

  String _buildHtml(String symbol, String interval) {
    final chartHeight = widget.height.toInt();
    final bg = _dark ? '#121212' : '#ffffff';
    final tema = _dark ? 'dark' : 'light';
    final grid = _dark ? 'rgba(255, 255, 255, 0.12)' : 'rgba(46, 46, 46, 0.2)';
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body { margin:0; padding:0; background:$bg; }
    .tradingview-widget-container {
      width: 100%;
      height: ${chartHeight}px;
    }
    .tradingview-widget-container__widget {
      width: 100%;
      height: ${chartHeight}px;
    }
  </style>
</head>
<body>
  <div class="tradingview-widget-container">
    <div class="tradingview-widget-container__widget"></div>
  </div>
  <script>
    var s = document.createElement('script');
    s.src = 'https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js';
    s.type = 'text/javascript';
    s.async = true;
    s.innerHTML = JSON.stringify({
      "allow_symbol_change": true,
      "calendar": false,
      "details": false,
      "hide_side_toolbar": true,
      "hide_top_toolbar": false,
      "hide_legend": false,
      "hide_volume": false,
      "hotlist": false,
      "interval": "$interval",
      "locale": "en",
      "save_image": false,
      "style": "1",
      "symbol": "$symbol",
      "theme": "$tema",
      "timezone": "Etc/UTC",
      "backgroundColor": "$bg",
      "gridColor": "$grid",
      "watchlist": [],
      "withdateranges": false,
      "compareSymbols": [],
      "support_host": "https://www.tradingview.com",
      "studies": [],
      "width": "100%",
      "height": $chartHeight
    });
    document.querySelector('.tradingview-widget-container').appendChild(s);
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: WebViewWidget(controller: _controller),
    );
  }
}