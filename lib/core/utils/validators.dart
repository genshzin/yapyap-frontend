
class Validators {
  
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (value.length > 30) {
      return 'Username cannot be longer than 30 characters';
    }
    
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }
  
  
  static String? validateFileSize(int fileSizeBytes, {int maxSizeBytes = 5 * 1024 * 1024}) {
    if (fileSizeBytes > maxSizeBytes) {
      final maxSizeMB = maxSizeBytes / (1024 * 1024);
      return 'File size cannot exceed ${maxSizeMB.toStringAsFixed(1)}MB';
    }
    return null;
  }
  
  
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  
  static String? validateImageFile(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return null; 
    }
    
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final extension = fileName.split('.').last.toLowerCase();
    
    if (!allowedExtensions.contains(extension)) {
      return 'Please select a valid image file (jpg, jpeg, png, gif)';
    }
    
    return null;
  }
}
