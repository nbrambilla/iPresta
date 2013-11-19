//
//  iPrestaNSError.m
//  iPresta
//
//  Created by Nacho on 08/05/13.
//  Copyright (c) 2013 Nacho. All rights reserved.
//

#import "iPrestaNSError.h"
#import "Language.h"

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
            message = [Language get:@"Problemas conexion" alter:nil];
            break;
        case URLCONNECTION_ERROR: // Error de conexión
            message = [Language get:@"Problemas conexion" alter:nil];
            break;
        case REQUESTTIMEOUT_ERROR: // Error de tiempo de conexion
            message = [Language get:@"Problemas conexion" alter:nil];
            break;
        case LOGIN_ERROR: // Error de Login
            message = [Language get:@"Email password error" alter:nil];
            break;
        case SIGNIN_ERROR: // Error de registro
            message = [Language get:@"Usuario existente" alter:nil];
            break;
        case REQUESTPASSWORDRESET_ERROR: // Error de recuperación de email
            message = [Language get:@"Usuario no existente" alter:nil];
            break;
        case NOTCURRENTUSER_ERROR: // Error al modificar un usuario que no es el logueado
            message = [Language get:@"Usuario no logueado" alter:nil];
            break;
        case EMPTYOBJECTDATA_ERROR: // Error al no encontrar ningun objeto
            message = [Language get:@"Objeto no encontrado" alter:nil];
            break;
        case REPEATOBJECT_ERROR: // no se ha devuelto ningun objeto de la busqueda
            message = [Language get:@"Objecto existente" alter:nil];
            break;
        case NOTAUTHENTICATEDUSER_ERROR:
            message = [Language get:@"Email no autenticado" alter:nil];
            break;
        case FBLOGINUSEREXISTS_ERROR:
            message = [NSString stringWithFormat:@"Ya existe una cuenta asociada al email %@. Loguese con su email y su password y vincule su cuenta con Facebook en configuración", [self.userInfo objectForKey:@"email"]];
            break;
        case FBLOGIN_ERROR:
            message = [Language get:@"Cuenta FB no existente" alter:nil];
            break;
        default:
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    alert = nil;
}
@end
