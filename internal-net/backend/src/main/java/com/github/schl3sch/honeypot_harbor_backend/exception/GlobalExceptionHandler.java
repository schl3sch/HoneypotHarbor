package com.github.schl3sch.honeypot_harbor_backend.exception;

import com.github.schl3sch.honeypot_harbor_backend.exception.dto.ApiError;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidationException(MethodArgumentNotValidException ex) {
        Map<String, String> fieldErrors = new HashMap<>();

        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            fieldErrors.put(fieldError.getField(), fieldError.getDefaultMessage());
        }
        ApiError error = new ApiError(
                HttpStatus.BAD_REQUEST,
                "Validation failed for one or more fields",
                fieldErrors.toString()
        );

        return new ResponseEntity<>(error, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleGenericException(Exception ex) {
        ApiError error = new ApiError(
                org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR,
                ex.getMessage(),
                "Unexpected error"
        );
        return new ResponseEntity<>(error, org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR);
    }
}


