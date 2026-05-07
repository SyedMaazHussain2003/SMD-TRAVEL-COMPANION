import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/travel_bloc.dart';
import '../bloc/theme_bloc.dart';
import '../widgets/place_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _filter = 'All';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<TravelBloc>().add(const FetchPlacesEvent());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<TravelBloc>().add(SearchPlacesEvent(_searchController.text));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _filter = 'All';
      } else if (index == 2) {
        _filter = 'Favorites';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Explore Places' : _selectedIndex == 1 ? 'Map View' : _selectedIndex == 2 ? 'My Favorites' : 'My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a'),
              ),
              accountName: const Text('Arjun Mehta'),
              accountEmail: const Text('arjun.mehta@email.com'),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map'),
              selected: _selectedIndex == 1,
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorites'),
              selected: _selectedIndex == 2,
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            const Divider(),
            BlocBuilder<ThemeBloc, ThemeMode>(
              builder: (context, themeMode) {
                return ListTile(
                  leading: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      context.read<ThemeBloc>().add(ToggleThemeEvent());
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 1) {
      return BlocBuilder<TravelBloc, TravelState>(
        builder: (context, state) {
          if (state is TravelLoaded) {
            final places = state.places;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Select a destination below to view its exact location on Google Maps.',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<TravelBloc>().add(const FetchPlacesEvent(isRefresh: true));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: places.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final place = places[index];
                        return ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(place.thumbnailUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(place.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('Lat: ${place.latitude.toStringAsFixed(2)}, Lon: ${place.longitude.toStringAsFixed(2)}', maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: SizedBox(
                            width: 80,
                            child: ElevatedButton(
                              onPressed: () async {
                                final url = 'https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}';
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Go', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
    
    if (_selectedIndex == 3) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a'),
            ),
            const SizedBox(height: 20),
            const Text('Arjun Mehta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('arjun.mehta@email.com', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () {}, child: const Text('Edit Profile')),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_selectedIndex == 0)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        if (_selectedIndex == 0)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Favorites', 'Recent'].map((filter) {
                final isSelected = _filter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _filter = filter;
                        if (filter == 'Favorites') _selectedIndex = 2;
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<TravelBloc, TravelState>(
            buildWhen: (previous, current) => current is TravelLoaded || current is TravelLoading || current is TravelError,
            builder: (context, state) {
              if (state is TravelLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TravelError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(state.message),
                      ElevatedButton(
                        onPressed: () {
                          context.read<TravelBloc>().add(const FetchPlacesEvent(isRefresh: true));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (state is TravelLoaded) {
                var places = state.places;
                if (_filter == 'Favorites' || _selectedIndex == 2) {
                  places = places.where((p) => p.isFavorite).toList();
                }

                if (places.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TravelBloc>().add(const FetchPlacesEvent(isRefresh: true));
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _selectedIndex == 2 ? 'No favorites yet!' : 'No places found!',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedIndex == 2 ? 'Start adding places to your favorites\nto see them here.' : 'Try adjusting your search\nor filter to find what\nyou\'re looking for.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),
                              if (_selectedIndex == 0)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _filter = 'All';
                                      _searchController.clear();
                                    });
                                    context.read<TravelBloc>().add(const FetchPlacesEvent());
                                  },
                                  child: const Text('Clear Filters'),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<TravelBloc>().add(const FetchPlacesEvent(isRefresh: true));
                  },
                  child: AnimatedList(
                    key: ValueKey('${places.length}_${places.where((p) => p.isFavorite).length}_${_filter}_${_selectedIndex}'),
                    initialItemCount: places.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index, animation) {
                      final place = places[index];
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: PlaceCard(
                            place: place,
                            onTap: () {
                              context.pushNamed('detail', extra: place);
                            },
                            onFavoriteToggle: () {
                              context.read<TravelBloc>().add(ToggleFavoriteEvent(place));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
