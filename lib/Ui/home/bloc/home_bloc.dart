import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:complaintsapp/AppClient/Models/complaint/add_complaint_req.dart';
import 'package:complaintsapp/AppClient/Models/complaint/add_complaint_res.dart';
import 'package:complaintsapp/AppClient/Services/_shared_prefs_helper.dart';
import 'package:complaintsapp/AppClient/Services/_urlApi.dart';
import 'package:complaintsapp/AppClient/Services/api_manager.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<NavigateMyComplaints>((event, emit) => emit(NavigationState(0)));
    on<NavigateSubmitComplaint>((event, emit) => emit(NavigationState(1)));
    on<SubmitComplaintEvent>(_submitComplaint);
  }

  var SubmitComplaintUri = "api/UserComplaints/CreateComplaint";
  var registerUri = "api/Auth/RegisterAppUser";

  Future<void> _submitComplaint(SubmitComplaintEvent event, Emitter<HomeState> emit) async {
    emit(AddComplaintLoading());

    try {
      // print(UrlApi.urlApiPor + SubmitComplaintUri); // Consider if this print is necessary or if UrlApi.staticUrl is the correct one to print
      final request = http.MultipartRequest("POST", (Uri.parse(UrlApi.urlApiPor + SubmitComplaintUri)));

      request.fields['ComplainTitle'] = event.addComplaintRequest.complainTitle;
      request.fields['ComplainDescription'] = event.addComplaintRequest.complainDescription;
      request.fields['CategoriesId'] = event.addComplaintRequest.categoriesId.toString();
      request.headers['Authorization'] = "Bearer ${SharedPrefs().token}";

      var imageFile = event.addComplaintRequest.image;
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'Image', // The key MUST match the property name in your C# DTO: 'Image'
          stream,
          length,
          filename: basename(imageFile.path), // Use path package to get the filename
        );
        request.files.add(multipartFile); // <-- Corrected: Add the multipartFile to the request
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      handleApiResponse(
          response: response,
          onSuccess: () async {
            var data = AddComplaintResponse.fromJson(json.decode(response.body));
            emit(AddComplaintSucess(addComplaintResponse: data));
          },
          onFailure: (message) {
            print("Failed to submit: $message");
            emit(AddComplaintFailur(error: message, AddComplaintResponse.fromJson(json.decode(response.body))));
          });
    } on FormatException catch (e) {
      // Handle cases where the response body is not valid JSON
      print("JSON parsing error on success: $e");
      emit(AddComplaintFailur(error: "Failed to parse successful response.", null));
    } catch (e) {
      // Get the response from the server
      handleException(
          e: e,
          onFailure: (message) {
            print("Failed to submit: $message");
            emit(
              AddComplaintFailur(error: message, null),
            );
          });
    }
  }
}
