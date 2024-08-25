import 'package:equatable/equatable.dart';
import '../../search_page/cubit/search_page_state.dart';

abstract class SearchResultsEvent extends Equatable {
  const SearchResultsEvent();

  @override
  List<Object> get props => [];
}

class LoadSearchResults extends SearchResultsEvent {
  final String name;
  final SearchMode mode;
  const LoadSearchResults({required this.name, required this.mode});

  @override
  List<Object> get props => [name, mode];
}
