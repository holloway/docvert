# -*- coding: utf-8 -*-
import os.path
import pipeline_item
import core.docvert_xml

class ConvertImages(pipeline_item.pipeline_stage):
    synonym_formats = dict( #Not just synonyms, but types of files that are converted using the same code
        'emf'='wmf',
        'jpe'='jpeg',
        'jpg'='jpeg'
    )

    def stage(self, pipeline_value):
        conversions = dict()

        # 1. Parse conversion requests
        formats = self.attributes["formats"].split(",")
        for format in formats:
            from_format, to_format = format.strip(" ._-").split("2")
            if from_format in self.synonym_formats.keys():
                from_format = self.synonym_formats[from_format]
            if not conversions.has_key(from_format):
                conversions[from_format] = list()
            conversions[from_format].append(to_format)
        
        # 2. Convert images
        # <stage process="ConvertImages" formats="wmf2png, wmf2svg, bmp2png" deleteOriginals="true" autoCrop="false" autoCropThreshold="20"/>
        storage_files = self.storage.keys()
        for storage_file in storage_files:
            if not storage_file.startswith(self.pipeline_storage_prefix):
                continue
            path, extension = os.path.splitext(storage_file)
            extension_minus_dot = extension[1:]
            if extension_minus_dot in formats.keys() and hasattr(self, "convert_%s" % extension_minus_dot):
                pipeline_value = getattr(self, "convert_%s" % extension_minus_dot, formats[extension_minus_dot], pipeline_value)

        # 3. Delete original images
        if self.attributes.has_key("deleteOriginals") and not self.attributes["deleteOriginals"].strip().lower() in ['false','f','n','0','']:
            for storage_file in storage_files:
                if not storage_file.startswith(self.pipeline_storage_prefix):
                    continue
                extension = os.path.splitext(storage_file)[1][1:]
                if extension in conversions.keys():
                    self.storage.remove(storage_file)
        #done
        return pipeline_value

        def convert_wmf(self, storage_path, to_format, pipeline_value):

            return pipeline_value


