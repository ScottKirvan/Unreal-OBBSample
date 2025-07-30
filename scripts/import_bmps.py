# ===============================================================
# Copyright (c) Meta Platforms, Inc. and affiliates.
# All rights reserved.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
# ===============================================================

import os

import unreal


def import_asset(source_file, destination_path):
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    import_task = unreal.AssetImportTask()
    import_task.filename = source_file
    import_task.destination_path = destination_path
    import_task.automated = True
    import_task.replace_existing = True
    import_task.save = True
    asset_tools.import_asset_tasks([import_task])


proj_dir = unreal.SystemLibrary.get_project_directory()
unreal.log("project directory: " + proj_dir)
import_asset(os.path.join(proj_dir, "tmp/bigfile.bmp"), "/Game/Chunk100/")
import_asset(os.path.join(proj_dir, "tmp/bigfile101.bmp"), "/Game/Chunk100/")
import_asset(os.path.join(proj_dir, "tmp/bigfile102.bmp"), "/Game/Chunk100/")
import_asset(os.path.join(proj_dir, "tmp/bigfile2.bmp"), "/Game/Chunk200/")
import_asset(os.path.join(proj_dir, "tmp/bigfile201.bmp"), "/Game/Chunk200/")
import_asset(os.path.join(proj_dir, "tmp/bigfile202.bmp"), "/Game/Chunk200/")
