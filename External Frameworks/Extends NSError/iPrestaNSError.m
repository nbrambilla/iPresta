//
//  iPrestaNSError.m
//  iPresta
//
//  Created by Nacho on 08/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaNSError.h"

@implementation NSError (iPrestaNSError)

- (id)initWithCode:(int)code userInfo:(NSDictionary *)userInfo
{
    self = [[NSError alloc] initWithDomain:@"error" code:code userInfo:userInfo];;
    return self;
}

- (void)manageErrorTo:(id)delegate
{
    NSString *message;
    
    switch ([self code]) {
        case CONNECTION_ERROR: // Error de conexión
            message = @"Problemas con la conexión. Intentelo otra vez.";
            break;
        case URLCONNECTION_ERROR: // Error de conexión
            message = @"Problemas con la conexión. Intentelo otra vez.";
            break;
        case REQUESTTIMEOUT_ERROR: // Error de tiempo de conexion
            message = @"Problemas con la conexión. Intentelo otra vez.";
            break;
        case LOGIN_ERROR: // Error de Login
            message = @"Email y/o password incorrecto/s";
            break;
        case SIGNIN_ERROR: // Error de registro
            message = @"Ya existe un usuario registrado con este email";
            break;
        case REQUESTPASSWORDRESET_ERROR: // Error de recuperación de email
            message = @"No existe un usuario registrado con este email";
            break;
        case NOTCURRENTUSER_ERROR: // Error al modificar un usuario que no es el logueado
            message = @"No se puede modificar los datos de un usuario que no esta logueado";
            break;
        case EMPTYOBJECTDATA_ERROR: // Error al modificar un usuario que no es el logueado
            message = @"No se ha encontrado este objeto. Ingrese los datos de forma manual";
            break;
        case REPEATOBJECT_ERROR: // no se ha devuelto ningun objeto de la busqueda
            message = @"Este objeto ya ha sido registrado";
            break;
        case NOTAUTHENTICATEDUSER_ERROR:
            message = @"Debe autenticar su email para poder acceder a la app";
            break;
        case FBLOGINUSEREXISTS_ERROR:
            message = [NSString stringWithFormat:@"Ya existe una cuenta asociada al email %@. Loguese con su email y su password y vincule su cuenta con Facebook en configuración", [self.userInfo objectForKey:@"email"]];
            break;
        case FBLOGIN_ERROR:
            message = [NSString stringWithFormat:@"No existe ninguna cuenta de Facebook asociada a este dispositivo."];
            break;
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    alert = nil;
}
@end
