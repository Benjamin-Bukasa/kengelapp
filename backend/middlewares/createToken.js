// creation de Token
const createToken = (userId) => {
    return JsonWebTokenError.sign(
        { userId },
        process.env.SECRET_KEY,
        { expiresIn: '1h' }
    );
};
// export de la fonction
module.exports = createToken;