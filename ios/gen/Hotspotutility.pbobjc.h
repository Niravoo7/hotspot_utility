// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: hotspotutility.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers.h>
#else
 #import "GPBProtocolBuffers.h"
#endif

#if GOOGLE_PROTOBUF_OBJC_VERSION < 30004
#error This file was generated by a newer version of protoc which is incompatible with your Protocol Buffer library sources.
#endif
#if 30004 < GOOGLE_PROTOBUF_OBJC_MIN_SUPPORTED_VERSION
#error This file was generated by an older version of protoc which is incompatible with your Protocol Buffer library sources.
#endif

// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

CF_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

#pragma mark - ProtosHotspotutilityRoot

/**
 * Exposes the extension registry for this file.
 *
 * The base class provides:
 * @code
 *   + (GPBExtensionRegistry *)extensionRegistry;
 * @endcode
 * which is a @c GPBExtensionRegistry that includes all the extensions defined by
 * this file and all files that it depends on.
 **/
GPB_FINAL @interface ProtosHotspotutilityRoot : GPBRootObject
@end

#pragma mark - Protoswifi_services_v1

typedef GPB_ENUM(Protoswifi_services_v1_FieldNumber) {
  Protoswifi_services_v1_FieldNumber_ServicesArray = 1,
};

GPB_FINAL @interface Protoswifi_services_v1 : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableArray<NSString*> *servicesArray;
/** The number of items in @c servicesArray without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger servicesArray_Count;

@end

#pragma mark - Protoswifi_connect_v1

typedef GPB_ENUM(Protoswifi_connect_v1_FieldNumber) {
  Protoswifi_connect_v1_FieldNumber_Service = 1,
  Protoswifi_connect_v1_FieldNumber_Password = 2,
};

GPB_FINAL @interface Protoswifi_connect_v1 : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *service;

@property(nonatomic, readwrite, copy, null_resettable) NSString *password;

@end

#pragma mark - Protoswifi_remove_v1

typedef GPB_ENUM(Protoswifi_remove_v1_FieldNumber) {
  Protoswifi_remove_v1_FieldNumber_Service = 1,
};

GPB_FINAL @interface Protoswifi_remove_v1 : GPBMessage

@property(nonatomic, readwrite, copy, null_resettable) NSString *service;

@end

#pragma mark - Protosdiagnostics_v1

typedef GPB_ENUM(Protosdiagnostics_v1_FieldNumber) {
  Protosdiagnostics_v1_FieldNumber_Diagnostics = 1,
};

GPB_FINAL @interface Protosdiagnostics_v1 : GPBMessage

@property(nonatomic, readwrite, strong, null_resettable) NSMutableDictionary<NSString*, NSString*> *diagnostics;
/** The number of items in @c diagnostics without causing the array to be created. */
@property(nonatomic, readonly) NSUInteger diagnostics_Count;

@end

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END

#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)