import 'package:flutter/material.dart';
import 'package:good_gut/services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'daily_tracking_page.dart';
import 'goals_page.dart';
import 'history_page.dart';
import 'info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _adsLoaded = false;
  final AdmobService _adService = AdmobService();

  final List<Widget> _pages = [
    const DailyTrackingPage(),
    const GoalsPage(),
    const HistoryPage(),
    const InfoPage(),
  ];

  @override
  void initState() {
    super.initState();
    _adService.addListener(_onAdStatusChanged);
  }

  @override
  void dispose() {
    _adService.removeListener(_onAdStatusChanged);
    super.dispose();
  }

  void _onAdStatusChanged(bool isLoaded) {
    setState(() {
      _adsLoaded = isLoaded;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;
    final diagonal = size.shortestSide;
    final aspectRatio = size.width / size.height;
    final isPhone = aspectRatio > 1.5 && aspectRatio < 2.5;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    _adService.loadAd(MediaQuery.of(context).size.width.truncate());

    return Scaffold(
      body: Row(
        children: [
          if (diagonal > 700 &&
              ((!isPhone && !isPortrait) || (!isPhone && isPortrait)))
            NavigationRail(
              extended: screenWidth > 800,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.today),
                  label: Text('Today'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.flag),
                  label: Text('Goals'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text('History'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info_outline),
                  label: Text('Info'),
                ),
              ],
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
            ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: diagonal > 700 &&
              ((!isPhone && isPortrait) || (!isPhone && !isPortrait))
          ? _adsLoaded && _adService.bannerAd != null
              ? Container(
                  height: 65,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: AdWidget(
                    ad: _adService.bannerAd!,
                  ),
                )
              : Container()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, Icons.today, 'Today'),
                      _buildNavItem(1, Icons.flag, 'Goals'),
                      _buildNavItem(2, Icons.history, 'History'),
                      _buildNavItem(3, Icons.info_outline, 'Info'),
                    ],
                  ),
                ),
                if (_adsLoaded && _adService.bannerAd != null)
                  Container(
                    height: 65,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: AdWidget(
                      ad: _adService.bannerAd!,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFFED4040)
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? const Color(0xFFED4040)
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
