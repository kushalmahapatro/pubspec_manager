class GitDependency {
  final String name;
  final String url;
  final String? ref;
  final String? path;

  const GitDependency({
    required this.name,
    required this.url,
    this.ref,
    this.path,
  });

  Map<String, dynamic> toMap() {
    if (ref == null && path == null) {
      return {
        name: url,
      };
    }

    return {
      name: {
        'git': {
          'url': url,
          if (ref != null) 'ref': ref,
          if (path != null) 'path': path,
        },
      },
    };
  }

  factory GitDependency.fromMap(Map<String, dynamic> map) {
    return GitDependency(
      name: map['name'] as String,
      url: map['url'] as String,
      ref: map['ref'] as String,
      path: map['path'] as String,
    );
  }
}

class PathDependency {
  final String name;
  final String path;

  const PathDependency({
    required this.name,
    required this.path,
  });

  Map<String, dynamic> toMap() {
    return {
      name: {
        'path': path,
      },
    };
  }

  factory PathDependency.fromMap(Map<String, dynamic> map) {
    return PathDependency(
      name: map['name'] as String,
      path: map['path'] as String,
    );
  }
}

class HostedDependency {
  final String name;
  final String hosted;
  final String? version;

  const HostedDependency({
    required this.name,
    required this.hosted,
    this.version = 'any',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': {
        'hosted': hosted,
        if (version != null) 'version': version,
      },
    };
  }

  factory HostedDependency.fromMap(Map<String, dynamic> map) {
    return HostedDependency(
      name: map['name'] as String,
      hosted: map['hosted'] as String,
      version: map['version'] as String,
    );
  }
}

class NormalDependency {
  final String name;
  final String? version;

  const NormalDependency({
    required this.name,
    this.version = 'any',
  });

  Map<String, dynamic> toMap() {
    return {
      name: version,
    };
  }

  factory NormalDependency.fromMap(Map<String, dynamic> map) {
    return NormalDependency(
      name: map['name'] as String,
      version: map['version'] as String,
    );
  }
}

class SdkDependency {
  final String name;
  final String? sdk;

  const SdkDependency({
    required this.name,
    required this.sdk,
  });

  Map<String, dynamic> toMap() {
    return {
      name: {
        'sdk': sdk,
      },
    };
  }

  factory SdkDependency.fromMap(Map<String, dynamic> map) {
    return SdkDependency(
      name: map['name'] as String,
      sdk: map['sdk'] as String,
    );
  }
}
