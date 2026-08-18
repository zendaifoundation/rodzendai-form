import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/services/service_locator.dart';
import 'package:rodzendai_form/models/project_model.dart';
import 'package:rodzendai_form/repositories/project_repository.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitial()) {
    on<LoadProjectsEvent>(_onLoadProjects);
  }

  Future<void> _onLoadProjects(
    LoadProjectsEvent event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    try {
      final repo = locator<ProjectRepository>();
      final projects = await repo.fetchProjects();
      emit(ProjectLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError('ไม่สามารถโหลดรายการโครงการได้: $e'));
    }
  }
}
