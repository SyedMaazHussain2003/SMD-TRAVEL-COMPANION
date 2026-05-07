import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/place.dart';
import '../bloc/travel_bloc.dart';
import '../widgets/weather_widget.dart';

class DetailPage extends StatefulWidget {
  final Place place;

  const DetailPage({super.key, required this.place});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    // Fetch weather when detail page opens
    context.read<TravelBloc>().add(FetchWeatherEvent(widget.place.latitude, widget.place.longitude));
  }

  Future<void> _openMap() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.place.latitude},${widget.place.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<TravelBloc>().add(FetchWeatherEvent(widget.place.latitude, widget.place.longitude));
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'place_image_${widget.place.id}',
                  child: CachedNetworkImage(
                    imageUrl: widget.place.url,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              actions: [
                BlocBuilder<TravelBloc, TravelState>(
                  buildWhen: (previous, current) => current is TravelLoaded,
                  builder: (context, state) {
                    Place currentPlace = widget.place;
                    if (state is TravelLoaded) {
                      final found = state.places.where((p) => p.id == widget.place.id);
                      if (found.isNotEmpty) {
                        currentPlace = found.first;
                      }
                    }
                    final bool isFav = currentPlace.isFavorite;
                    
                    return Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          context.read<TravelBloc>().add(ToggleFavoriteEvent(currentPlace));
                        },
                      ),
                    );
                  },
                )
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Location ID: ${widget.place.id}',
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    BlocBuilder<TravelBloc, TravelState>(
                      buildWhen: (previous, current) => current is TravelLoaded,
                      builder: (context, state) {
                        if (state is TravelLoaded) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildWeatherState(state),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'About this place',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.place.description,
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[700], height: 1.5),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDescriptionExpanded = !_isDescriptionExpanded;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                _isDescriptionExpanded ? 'Read Less' : 'Read More',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openMap,
                        icon: const Icon(Icons.map),
                        label: const Text('View on Map'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherState(TravelLoaded state) {
    if (state.isWeatherLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.weather != null) {
      return WeatherWidget(key: const ValueKey('loaded'), weather: state.weather!);
    } else {
      return Container(
        key: const ValueKey('error'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(25, 244, 67, 54),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text('Weather data currently unavailable offline', style: const TextStyle(color: Colors.red))),
          ],
        ),
      );
    }
  }
}
