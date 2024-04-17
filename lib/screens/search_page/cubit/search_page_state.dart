import 'package:equatable/equatable.dart';
import 'package:food_recipe_app/models/auto_complete.dart';

///Search Page States
enum Status { loading, initial, success, failure }

class SearchPageState extends Equatable {
  final Status status;
  final String searchText;

  final List<SearchAutoComplete> searchList;
  const SearchPageState({
    required this.status,
    required this.searchText,
    required this.searchList,
  });

  factory SearchPageState.initial() {
    return const SearchPageState(
      status: Status.initial,
      searchText: '',
      searchList: [],
    );
  }

  @override
  List<Object> get props => [
        status,
        searchText,
        searchList,
      ];

  SearchPageState copyWith({
    Status? status,
    String? searchText,
    String? searchValue,
    List<SearchAutoComplete>? searchList,
  }) {
    return SearchPageState(
      status: status ?? this.status,
      searchText: searchText ?? this.searchText,
      searchList: searchList ?? this.searchList,
    );
  }
}
